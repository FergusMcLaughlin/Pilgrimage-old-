class_name EffectActionQueryDirector

var sourceCard: Node2D
var effectDefinitions: Dictionary = {}

func _init(card: Node2D):
	sourceCard = card
	loadEffectDefinitions()

func loadEffectDefinitions():
	if DictionaryJsonLoader.effectData.is_empty():
		await DictionaryJsonLoader.ready
	
	effectDefinitions = DictionaryJsonLoader.effectData
	print("EffectActionQueryDirector: Loaded ", effectDefinitions.size(), " effect definitions")

func processEffectsForTrigger(triggerType: String, eventContext: Dictionary = {}):
	if !sourceCard || !sourceCard.cardEffects:
		return
	
	print("EffectActionQueryDirector: Processing effects for trigger: ", triggerType)
	
	for effectId in sourceCard.cardEffects:
		var effectData = effectDefinitions.get(effectId, {})
		
		if effectData.is_empty():
			print("EffectActionQueryDirector: no effects found for trigger")
			continue
		
		processEffect(effectData, triggerType, eventContext)

func processEffect(effectData: Dictionary, triggerType: String, eventContext: Dictionary):
	var effectTrigger = effectData.get("trigger", "")
	if effectTrigger != triggerType:
		return
	
	#When
	var queryResult = null
	if effectData.has("when"):
		queryResult = BoardQuery.executeQuery(effectData["when"])
		if !checkCondition(effectData["when"], queryResult):
			print("EffectActionQueryDirector: Condition not met, skipping effect")
			return
	
	#What
	if effectData.has("what"):
		executeActions(effectData["what"], queryResult)

func checkCondition(whenData: Dictionary, queryResult):
	var minCount = whenData.get("min_count", 0)
	
	if queryResult is int:
		return queryResult >= minCount
	elif queryResult is Array:
		return queryResult.size() >= minCount
	elif queryResult is Dictionary:
		return queryResult.get("matched", false)
	
	return queryResult != null

func executeActions(whatData, queryResult):
	if whatData.has("action"):
		var success = BoardAction.executeAction(whatData, queryResult, sourceCard)
		print("EffectActionQueryDirector: Action executed with result: ", success)
		
		if success && whatData.has("then"):
			executeActions(whatData["then"], queryResult)
		
	elif whatData is Array:
		for actionData in whatData:
			executeActions(actionData, queryResult)
	
#___________________________________________________________________________________________________

func onSlotFilled(slot, card):
	processEffectsForTrigger("slot_filled", {"slot": slot, "card": card})

func onSlotEmptied(slot):
	processEffectsForTrigger("slot_emptied", {"slot": slot})

func onCardPlayed(card, slot):
	processEffectsForTrigger("card_played", {"card": card, "slot": slot})

func onCardDrawn(card):
	processEffectsForTrigger("card_drawn", {"card": card})

func onBoardStateChanged():
	processEffectsForTrigger("board_state_changed", {})
