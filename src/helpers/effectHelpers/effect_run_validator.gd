class_name EffectRunValidator

static var cardStates: Dictionary = {}

static func getEffectsToRun(effects: Array[CardEffect], trigger: String, context: Dictionary):
	var effectsToRun = []
	
	for effect in effects:
		if !effect.shouldRunEffectCheck(trigger, context):
			continue
		
		var key = str(effect.hostCard.get_instance_id()) + "_" + effect.effectName
		var currentState = getCurrentValue(effect)
		var lastState = cardStates.get(key, {})
		
		if currentState != lastState or trigger == "slot_emptied" or trigger == "card_removed":
			cardStates[key] = currentState
			effectsToRun.append(effect)
	
	return effectsToRun

static func getCurrentValue(effect: CardEffect):
	if effect.effectData.get("type") == "stat_augmentation":
		var targetType = effect.effectData.get("target_card_type", "")
		var targetName = effect.effectData.get("target_card_name", "")
		var count =  BoardQueryHelper.countCardsOfType(targetType, targetName)
		
		return {
			"target_count": count,
			"effect_type": "stat_augmentation",
			"target_type": targetType,
			"target_name": targetName
		}
	else:
		var board = BoardQueryHelper.getCurrentBoard()
		var occupiedCount = board.getOccupiedSlots().size() if board else 0
		return {
			"occupied_slots": occupiedCount,
			"effect_type": "general"
		}

static func getCardKey(card: Node2D) -> String:
	return str(card.get_instance_id())

static func clearCard(card: Node2D):
	var key = getCardKey(card)
	cardStates.erase(key)
