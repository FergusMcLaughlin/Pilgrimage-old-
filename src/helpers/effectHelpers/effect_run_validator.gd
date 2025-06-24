class_name EffectRunValidator

static var lastTargetCounts: Dictionary = {}

static func getEffectsToRun(effects: Array[CardEffect], trigger: String, context: Dictionary):
	var effectsToRun = []
	
	for effect in effects:
		if !effect.shouldRunEffectCheck(trigger, context):
			continue
		
		if effect.effectData.get("type") == "stat_augmentation":
			var targetType = effect.effectData.get("target_card_type", "")
			var targetName = effect.effectData.get("target_card_name", "")
			var currentCount =  BoardQueryHelper.countCardsOfType(targetType, targetName)
		
			var key = str(effect.hostCard.get_instance_id()) + "_" + targetType + "_" + targetName
			var lastCount = lastTargetCounts.get(key, -1)
		
			if currentCount != lastCount:
				print("SimpleEffectTracker: Target count changed from ", lastCount, " to ", currentCount, " for ", effect.effectName)
				lastTargetCounts[key] = currentCount
				effectsToRun.append(effect)
			else:
				print("SimpleEffectTracker: No change in target count (", currentCount, ") for ", effect.effectName)
		else:
			# For other effect types, always run (you can customize this later)
			effectsToRun.append(effect)
	
	return effectsToRun

static func clearCard(card: Node2D):
	var cardId = str(card.get_instance_id())
	var keysToRemove = []
	
	for key in lastTargetCounts:
		if key.begins_with(cardId + "_"):
			keysToRemove.append(key)
	
	for key in keysToRemove:
		lastTargetCounts.erase(key)
