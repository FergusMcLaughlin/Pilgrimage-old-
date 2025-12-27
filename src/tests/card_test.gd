extends Node2D

@onready var playerDeck = $GameBoard/playerDeck
@onready var journeyDeck = $GameBoard/journeyDeck
@onready var cardGrid = $GameBoard/CardGrid

func _ready() -> void:
	print(ActionTypes.PLAY_CARD)
	playerDeck.initialiseFromPreset("test")
	journeyDeck.initialiseJourneyDeck()

	print("\n----- SCENE DEBUG INFO -----")
	ActionQueue.actionEnqueued.connect(func(a): print("ENQUEUED ", a.get("type")))
	ActionQueue.actionPopped.connect(func(a): print("POPPED ", a.get("type")))

	ActionQueue.enqueueAction({"type": ActionTypes.PLAY_CARD})
	ActionQueue.enqueueAction({"type": ActionTypes.MODIFY_STATS})

	ActionQueue.popNextAction()
	ActionQueue.popNextAction()
	ActionQueue.popNextAction()
	# UI wiring
	$Ui/ButtonPanel/fill_board.pressed.connect(on_fill_board_button_pressed)
	$Ui/ButtonPanel/fill_one_slot.pressed.connect(on_fill_one_slot_button_pressed)
	$Ui/ButtonPanel/debug_button.pressed.connect(on_debug_button_pressed)

	# Set globals
	GameController.boardController = $GameBoard
	GameController.playerDeck = playerDeck
	GameController.journeyDeck = journeyDeck
	GameController.hand = $GameBoard/Hand

	GameController.setupBoard()

	# Boot diagnostics
	await debug_effect_system_boot()

	# Immediately try to locate a solitary_beast card already spawned during setup
	await get_tree().process_frame
	await find_and_force_solitary_beast()


# -----------------------------
# EFFECT SYSTEM BOOT DIAGNOSTICS
# -----------------------------
func debug_effect_system_boot() -> void:
	print("\n----- EFFECT SYSTEM BOOT DIAGNOSTICS -----")

	print("Has CardDataRegistry autoload: ", _has_singleton("CardDataRegistry"))
	print("Has EffectDictionaryJsonLoader autoload: ", _has_singleton("EffectDictionaryJsonLoader"))
	print("Has EffectDataRegistry autoload: ", _has_singleton("EffectDataRegistry"))

	# Wait for effect registry to populate
	if _has_singleton("EffectDataRegistry"):
		if EffectDataRegistry.effectDataById.is_empty():
			print("EffectDataRegistry empty -> awaiting ready")
			await EffectDataRegistry.ready

		print("EffectDataRegistry.size: ", EffectDataRegistry.effectDataById.size())
		print("EffectDataRegistry.keys: ", EffectDataRegistry.effectDataById.keys())

		if EffectDataRegistry.effectDataById.has("solitary_beast"):
			var ed: EffectData = EffectDataRegistry.getEffectData("solitary_beast")
			print("solitary_beast EffectData => id=", ed.effectId, " type=", ed.effectType, " trigger=", ed.effectTrigger)
		else:
			print("WARNING: solitary_beast missing from EffectDataRegistry")


# -----------------------------
# MAIN TEST: find a spawned card with solitary_beast and force apply
# -----------------------------
func find_and_force_solitary_beast() -> void:
	print("\n----- SOLITARY BEAST LIVE CARD TEST -----")

	if not _has_singleton("CardDataRegistry"):
		print("ERROR: CardDataRegistry missing as autoload")
		return

	# Find any instantiated Card nodes in the scene tree
	var cards := find_all_cards_in_scene()
	print("Found ", cards.size(), " cards in scene")

	# Pick first card whose CardData has solitary_beast
	for card in cards:
		if not _has_prop(card, "cardId"):
			continue

		var card_id: String = str(_get_prop(card, "cardId"))
		var data: CardData = CardDataRegistry.getCardData(card_id)
		if data == null:
			continue

		if data.cardEffects.has("solitary_beast"):
			print("Found solitary_beast card in scene: ", _get_prop(card, "cardName"), " (id=", card_id, ")")
			await force_setup_and_apply(card, data)
			return

	print("No instantiated card with solitary_beast found yet.")
	print("Press 'fill_one_slot' or 'fill_board' then press 'debug_button' to retry.")


func force_setup_and_apply(card: Node2D, data: CardData) -> void:
	print("\n--- FORCING EFFECT SETUP ---")
	print("Target card: ", _get_prop(card, "cardName"), " id=", _get_prop(card, "cardId"))
	print("CardData.effects: ", data.cardEffects)

	# Stats before
	_print_card_stats("BEFORE", card)

	# Pull effect data
	var effect_id := "solitary_beast"
	var effectData: EffectData = EffectDataRegistry.getEffectData(effect_id)
	print("EffectData: id=", effectData.effectId, " type=", effectData.effectType)

	# Force factory creation
	print("Calling CardEffectFactory.createCardEffect...")
	var cardEffect = CardEffectFactory.createCardEffect(card, effectData)
	print("Factory returned: ", cardEffect)

	if cardEffect == null:
		print("FAIL: factory returned null.")
		print("This means your factory match does not accept effectType='", effectData.effectType, "' (or it is still expecting a Dictionary).")
		return

	# Register
	print("Registering listener via EffectMediator.addListner...")
	EffectMediator.addListner(card, cardEffect)
	print("Registered.")

	# Force apply NOW
	if cardEffect.has_method("apply"):
		print("Calling apply() immediately...")
		cardEffect.apply()
	else:
		print("FAIL: cardEffect has no apply() method")
		return

	# Stats after
	_print_card_stats("AFTER", card)

	print("If BEFORE == AFTER, then apply() ran but made no change.")
	print("Next check is SolitaryBeast.checkWoodsCardsOnBoard() returning 0 (expected if Woods doesn’t exist).")


# -----------------------------
# Buttons
# -----------------------------
func on_fill_board_button_pressed() -> void:
	print("\n----- FILL BOARD BUTTON PRESSED -----")
	journeyDeck.fillEmptySlots()

func on_fill_one_slot_button_pressed() -> void:
	print("\n----- FILL ONE SLOT BUTTON PRESSED -----")
	var emptySlot = find_first_empty_slot()
	if emptySlot:
		journeyDeck.revealTopCard(emptySlot)

func on_debug_button_pressed() -> void:
	# Retry the solitary beast scan/apply after you’ve filled board/slot
	await get_tree().process_frame
	await find_and_force_solitary_beast()


# -----------------------------
# Helpers
# -----------------------------
func find_first_empty_slot() -> Node:
	if cardGrid and cardGrid.has_method("getEmptySlots"):
		var emptySlots = cardGrid.getEmptySlots()
		if not emptySlots.is_empty():
			return emptySlots[0]

	var slots = get_tree().get_nodes_in_group("cardSlot")
	for slot in slots:
		if not _get_prop(slot, "cardInSlot", false):
			return slot
	return null


func find_all_cards_in_scene() -> Array:
	var result: Array = []
	_collect_cards(self, result)
	return result

func _collect_cards(node: Node, out: Array) -> void:
	# Heuristic: your card scenes are Node2D with cardId/cardName fields
	if node is Node2D and _has_prop(node, "cardId") and _has_prop(node, "cardName"):
		out.append(node)
	for c in node.get_children():
		_collect_cards(c, out)


func _print_card_stats(prefix: String, card: Node2D) -> void:
	var atk  = _get_prop(card, "cardAttack", "?")
	var hp   = _get_prop(card, "cardHealth", "?")
	var batk = _get_prop(card, "cardBaseAttack", "?")
	var bhp  = _get_prop(card, "cardBaseHealth", "?")
	print(prefix, " ", _get_prop(card, "cardName", "<unknown>"),
		" atk=", atk, " hp=", hp, " baseAtk=", batk, " baseHp=", bhp)


func print_scene_tree(node = null, indent = "") -> void:
	if node == null:
		node = self
		print("Scene tree structure:")
	print(indent + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + "  ")


# ---- Property helpers for Godot 4 (no has_variable) ----
func _has_prop(obj: Object, prop_name: String) -> bool:
	for p in obj.get_property_list():
		if String(p.name) == prop_name:
			return true
	return false

func _get_prop(obj: Object, prop_name: String, default_value = null):
	if _has_prop(obj, prop_name):
		return obj.get(prop_name)
	return default_value


func _has_singleton(name: String) -> bool:
	return get_node_or_null("/root/" + name) != null
