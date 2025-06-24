extends Node
class_name CardEffectManager

var activeEffects: Array[CardEffect] = []
var effectDefinitions: Dictionary = {}

var effectTimer: EffectTimerHelper
var effectBatcherHelper: EffectBatcherHelper
var setupPhase: bool = true

const TIME_PER_BATCH = 1

func _ready():
	effectTimer = EffectTimerHelper.new(self)
	effectBatcherHelper = EffectBatcherHelper.new()
	
	await loadEffectDeffinitions()
	connectToSignals()

func loadEffectDeffinitions():
	if CardEffectDictionaryJsonLoader.cardEffectData.is_empty():
		await CardEffectDictionaryJsonLoader.ready
	
	effectDefinitions = CardEffectDictionaryJsonLoader.cardEffectData

func connectToSignals():
	GlobalSignalBus.connect("slotFilled", onSlotFilled)
	GlobalSignalBus.connect("slotEmptied", onSlotEmptied)
	GlobalSignalBus.connect("battleCompleted", onBattleCompleted)
	GlobalSignalBus.connect("boardSetupComplete", onBoardSetupComplete)

func onBoardSetupComplete():
	setupPhase = false
	print("CardEffectManager: Setup phase complete, effects now active")

func onSlotFilled(slot, card):
	addCardEffects(card)
	if not setupPhase:
		checkEffects("slot_filled", {"slot": slot, "card": card})

func onSlotEmptied(slot):
	if not setupPhase:
		checkEffects("slot_emptied", {"slot": slot})

func onBattleCompleted(attacker, defender, result):
	if result.has("attackerDied") and result.attackerDied:
		removeCardEffects(attacker)

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
	EffectRunValidator.clearCard(card)
	
	if not setupPhase:
		await get_tree().process_frame
		checkEffects("card_removed", {"card": card})

func checkEffects(trigger: String, context: Dictionary):
	if setupPhase:
		return
	
	cleanupFreedCards()
	
	var effectsToRun = EffectRunValidator.getEffectsToRun(activeEffects, trigger, context)
	
	if effectsToRun.is_empty():
		return
	
	var batches = effectBatcherHelper.create_batches(effectsToRun)
	GlobalSignalBus.emit_signal("effectsStarted")
	effectTimer.startBatchSequence(batches, TIME_PER_BATCH, exicuteBatch)

func exicuteBatch(batch: Array):
	for effect in batch:
		if is_instance_valid(effect.hostCard):
			effect.applyCardEffect({})
			
	if effectTimer.currentBatch >= effectTimer.batches.size():
		GlobalSignalBus.emit_signal("effectsFinished")
