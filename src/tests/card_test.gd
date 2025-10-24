extends Node2D

var current_test_card: Node2D = null
@onready var playerDeck: Node = $GameBoard/playerDeck
@onready var journeyDeck: Node = $GameBoard/journeyDeck
@onready var cardGrid: Node = $GameBoard/CardGrid

# -------------------------------------------------------------------
# DEBUG HELPERS
# -------------------------------------------------------------------

func _await_if_signal(obj: Object, signal_name: String) -> void:
	if not obj.is_connected(signal_name, Callable(self, "_noop")):
		if obj.has_signal("ready"):
			await obj.ready

func _noop() -> void:
	pass

func print_header(title: String) -> void:
	print("\n================ ", title, " ================\n")

func assert_autoload_exists(name: String) -> bool:
	var path: String = "/root/" + name
	var exists: bool = has_node(path)
	if not exists:
		push_error("❌ Autoload missing: " + name + " (expected at " + path + ")")
	else:
		print("✅ Autoload present:", name)
	return exists

func print_builder_snapshot() -> void:
	if not assert_autoload_exists("GameDataBuilder"):
		return
	var builder: Node = get_node("/root/GameDataBuilder")
	var card_count: int = builder.cards.size() if builder.cards else 0
	var effect_count: int = builder.effects.size() if builder.effects else 0
	print("GameDataBuilder snapshot → Cards:", card_count, " | Effects:", effect_count)
	if card_count == 0:
		push_warning("⚠️ GameDataBuilder.cards is empty (check autoload order: loaders must be before GameDataBuilder).")

	var n: int = 0
	for k in builder.cards.keys():
		var cd: CardData = builder.cards[k]
		print("-", k, "|", cd.name, "| type:", cd.type)
		n += 1
		if n >= 5:
			break

func verify_create_card() -> void:
	if not assert_autoload_exists("CreateCard"):
		return
	var cc: Node = get_node("/root/CreateCard")
	var ok: bool = cc.has_method("createCard")
	print("CreateCard.createCard present:", ok)

func verify_decks() -> void:
	print_header("DECK STATUS")
	if playerDeck:
		var has_init: bool = playerDeck.has_method("initialiseFromPreset")
		var has_draw: bool = playerDeck.has_method("drawCard")
		print("PlayerDeck found. Methods → initialiseFromPreset:", has_init, " drawCard:", has_draw)
	else:
		push_error("❌ playerDeck node missing under GameBoard")

	if journeyDeck:
		var has_init_j: bool = journeyDeck.has_method("initialiseJourneyDeck")
		var has_reveal: bool = journeyDeck.has_method("revealTopCard")
		var has_fill: bool = journeyDeck.has_method("fillEmptySlots")
		print("JourneyDeck found. Methods → initialiseJourneyDeck:", has_init_j, " revealTopCard:", has_reveal, " fillEmptySlots:", has_fill)
	else:
		push_error("❌ journeyDeck node missing under GameBoard")

func verify_board_slots() -> void:
	print_header("BOARD / SLOTS")
	if cardGrid and cardGrid.has_method("getEmptySlots"):
		var empty: Array = cardGrid.getEmptySlots()
		print("CardGrid.getEmptySlots() →", empty.size())
	else:
		print("CardGrid:", cardGrid != null, " has getEmptySlots:", cardGrid and cardGrid.has_method("getEmptySlots"))
	var slots: Array = get_tree().get_nodes_in_group("cardSlot")
	print("Slots in group 'cardSlot':", slots.size())
	if slots.is_empty():
		push_warning("⚠️ No nodes in group 'cardSlot'. Ensure your CardSlot scenes are added to group 'cardSlot'.")

func smoke_spawn_specific(card_id: String) -> void:
	if not assert_autoload_exists("CreateCard"):
		return
	var cc: Node = get_node("/root/CreateCard")
	if not cc.has_method("createCard"):
		push_error("❌ CreateCard.createCard not found.")
		return
	var card: Node2D = cc.createCard(card_id)
	if card == null:
		push_error("❌ Smoke spawn failed for " + card_id + " (builder lookup or scene init failed).")
		return
	add_child(card)
	card.global_position = Vector2(300, 300)
	print("✅ Smoke-spawned:", card_id, " → ", card.get_class(), " at (300,300)")

func smoke_spawn_first_unit() -> void:
	if not assert_autoload_exists("GameDataBuilder") or not assert_autoload_exists("CreateCard"):
		return
	var builder: Node = get_node("/root/GameDataBuilder")
	for id in builder.cards.keys():
		var cd: CardData = builder.cards[id]
		if cd.type == "unit":
			smoke_spawn_specific(id)
			return
	push_warning("⚠️ No unit cards found to smoke-spawn.")

# -------------------------------------------------------------------
# ORIGINAL FLOW + ADDED CHECKS
# -------------------------------------------------------------------

func _ready() -> void:
	print_header("AUTOLOAD CHECK")
	var ok_cards: bool = assert_autoload_exists("CardDictionaryJsonLoader")
	var ok_effects: bool = assert_autoload_exists("EffectDictionaryJsonLoader")
	var ok_builder: bool = assert_autoload_exists("GameDataBuilder")
	var ok_create: bool = assert_autoload_exists("CreateCard")

	print_header("BUILDER SNAPSHOT")
	if ok_builder:
		print_builder_snapshot()

	print_header("CREATECARD CHECK")
	if ok_create:
		verify_create_card()

	TaskQ.enqueueTask(func(): print("instant task done"), [], 0.0, "Instant")
	TaskQ.enqueueTask(func(): print("delayed task done"), [], 1.5, "Delayed")
	TaskQ.enqueueTask(func():
		await get_tree().create_timer(2.0).timeout
		print("async task done"),
		[], 0.0, "Async")

	smoke_spawn_specific("M_0002")  # Goatman test spawn

	spawn_test_card()
	playerDeck.initialiseFromPreset("test")
	journeyDeck.initialiseJourneyDeck()

	verify_decks()
	verify_board_slots()

	print_header("SCENE TREE")
	print_scene_tree()

	$Ui/ButtonPanel/findmiddleslotButton.pressed.connect(on_flip_button_pressed)
	$Ui/ButtonPanel/StateButton.pressed.connect(on_change_state_button_pressed)
	$Ui/ButtonPanel/DragButton.pressed.connect(on_test_drag_button_pressed)
	$Ui/ButtonPanel/MoveToSlotButton.pressed.connect(on_move_to_slot_button_pressed)
	$Ui/ButtonPanel/RemoveFromSlotButton.pressed.connect(on_remove_from_slot_button_pressed)
	$Ui/ButtonPanel/debug_button.pressed.connect(on_debug_button_pressed)
	$Ui/ButtonPanel/fill_board.pressed.connect(on_fill_board_button_pressed)
	$Ui/ButtonPanel/fill_one_slot.pressed.connect(on_fill_one_slot_button_pressed)

	print_header("BUTTON CONNECTIONS")
	print("- FlipButton connected: ", $Ui/ButtonPanel/findmiddleslotButton.is_connected("pressed", Callable(self, "on_flip_button_pressed")))
	print("- StateButton connected: ", $Ui/ButtonPanel/StateButton.is_connected("pressed", Callable(self, "on_change_state_button_pressed")))
	print("- DragButton connected: ", $Ui/ButtonPanel/DragButton.is_connected("pressed", Callable(self, "on_test_drag_button_pressed")))
	print("- MoveToSlotButton connected: ", $Ui/ButtonPanel/MoveToSlotButton.is_connected("pressed", Callable(self, "on_move_to_slot_button_pressed")))
	print("- RemoveFromSlotButton connected: ", $Ui/ButtonPanel/RemoveFromSlotButton.is_connected("pressed", Callable(self, "on_remove_from_slot_button_pressed")))
	print("- debug_button connected: ", $Ui/ButtonPanel/debug_button.is_connected("pressed", Callable(self, "on_debug_button_pressed")))
	print("- fill_board connected: ", $Ui/ButtonPanel/fill_board.is_connected("pressed", Callable(self, "on_fill_board_button_pressed")))
	print("- fill_one_slot connected: ", $Ui/ButtonPanel/fill_one_slot.is_connected("pressed", Callable(self, "on_fill_one_slot_button_pressed")))

	GameController.boardController = $GameBoard
	GameController.playerDeck = $GameBoard/playerDeck
	GameController.journeyDeck = $GameBoard/journeyDeck
	GameController.hand = $GameBoard/Hand
	GameController.setupBoard()

# ---------- UI and helper handlers ----------

func on_fill_board_button_pressed() -> void:
	print_header("ACTION: FILL BOARD")
	if journeyDeck:
		journeyDeck.fillEmptySlots()
	else:
		print("ERROR: JourneyDeck not found or initialized")

func on_fill_one_slot_button_pressed() -> void:
	print_header("ACTION: FILL ONE SLOT")
	if journeyDeck:
		var emptySlot: Node = find_first_empty_slot()
		if emptySlot:
			var card: Node2D = journeyDeck.revealTopCard(emptySlot)
			if card:
				print("Placed card ", card.cardName, " in slot")
			else:
				print("No more cards in journey deck")
		else:
			print("No empty slots found on board")
	else:
		print("ERROR: JourneyDeck not found or initialized")

func find_first_empty_slot() -> Node:
	if cardGrid and cardGrid.has_method("getEmptySlots"):
		var emptySlots: Array = cardGrid.getEmptySlots()
		if not emptySlots.is_empty():
			return emptySlots[0]
	var slots: Array = get_tree().get_nodes_in_group("cardSlot")
	for slot in slots:
		if not slot.cardInSlot:
			return slot
	return null

func print_scene_tree(node: Node = null, indent: String = "") -> void:
	if node == null:
		node = self
		print("Scene tree structure:")
	print(indent + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		print_scene_tree(child, indent + "  ")

# Stubs kept typed
func spawn_test_card() -> void: pass
func on_flip_button_pressed() -> void: pass
func on_change_state_button_pressed() -> void: pass
func on_test_drag_button_pressed() -> void: pass
func on_move_to_slot_button_pressed() -> void: pass
func on_remove_from_slot_button_pressed() -> void: pass
func move_card_to_slot(slot: Node) -> void: pass
func remove_card_from_slot(slot: Node) -> void: pass
func on_debug_button_pressed() -> void: pass
func print_card_debug_info(card: Node) -> void: pass
func find_all_cards_in_scene() -> void: pass
func find_hand_node() -> void: pass
func find_node_by_name(node_name: String, current_node: Node = null) -> void: pass
