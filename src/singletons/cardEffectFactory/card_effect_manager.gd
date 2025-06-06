extends Node
class_name CardEffectManager

var activeEffects: Array[CardEffect] = []
var effectDefinitions: Dictionary = {}

func _ready():
	if CardEffectDictionaryJsonLoader.cardEffectData.is_empty():
		await CardEffectDictionaryJsonLoader.ready
	
	effectDefinitions = CardEffectDictionaryJsonLoader.cardEffectData
	print("CardEffectManager: Loaded ", effectDefinitions.size(), " effect definitions")
	
	connectToSignals()
	

func connectToSignals():
	GlobalSignalBus.connect("boardStateChanged", onBoardStateChanged)
	GlobalSignalBus.connect("cardPlayed", onCardPlayed)
	GlobalSignalBus.connect("slotFilled", onSlotFilled)
	GlobalSignalBus.connect("cardMoved", onCardMoved)#look at these
	
	GlobalSignalBus.connect("battleCompleted", onBattleCompleted)

func addCardEffects(card: Node2D):
	var cardData = CardDictionaryJsonLoader.cardData.get(card.cardId, {})
	var cardEffects = cardData.get("effects", [])
	
	for individualEffect in cardEffects:
		var effectData = effectDefinitions.get(individualEffect,{})
		if !effectData.is_empty():
			var effect = CardEffectFactory.createEffect(card, effectData)
			if effect:
				activeEffects.append(effect)

func cleanupFreedCards():
	activeEffects = activeEffects.filter(func(effect): return is_instance_valid(effect.hostCard))

func removeCardEffects(card: Node2D):
	activeEffects = activeEffects.filter(func(effect): return effect.hostCard != card)

func onBoardStateChanged():
	cleanupFreedCards()
	checkAndApplyEffects("board_changed", {})

func onCardPlayed(card, slot):
		checkAndApplyEffects("card_played", {
		"card": card,
		"slot": slot
		})

func onSlotFilled(slot, card):
	addCardEffects(card)
	checkAndApplyEffects("slot_filled", {
		"card": card,
		"slot": slot
		})

func onCardMoved(card, fromSlot, toSlot):
	checkAndApplyEffects("card_moved", {
		"card":card,
		"from":fromSlot,
		"to":toSlot
	})

func onBattleCompleted(attacker, defender, result):
	if result.has("attackerDied") and result.attackerDied:
		removeCardEffects(attacker)

func checkAndApplyEffects(triggerType: String, context: Dictionary):
	cleanupFreedCards()
	
	for effect in activeEffects:
		if effect.shouldRunEffectCheck(triggerType, context):
			effect.applyCardEffect(context)
