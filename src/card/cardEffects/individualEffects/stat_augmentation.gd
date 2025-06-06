class_name StatAugmentation
extends CardEffect


func shouldRunEffectCheck(triggerType: String, context: Dictionary) -> bool:
	var expectedTrigger = effectData.get("trigger", "")
	if triggerType != "slot_filled":
		return false
	
	var targetCardType = effectData.get("target_card_type", "")
	var targetCardName = effectData.get("target_card_name", "")
	var forestCardsOnBoard = BoardQueryHelper.countCardsOfType(targetCardType, targetCardName)
	
	return forestCardsOnBoard > 0

func applyCardEffect(context: Dictionary) -> void:
	var targetCardType = effectData.get("target_card_type", "")
	var targetCardName = effectData.get("target_card_name", "")
	var cardsOnBoard = BoardQueryHelper.countCardsOfType(targetCardType, targetCardName)
	
	hostCard.resetToBaseStats()
	
	var statBoostAmount = 0
	if effectData.get("stat_boost"):
		statBoostAmount = effectData.get("stat_change", 0) * cardsOnBoard
	else:
		statBoostAmount = -effectData.get("stat_change", 0) * cardsOnBoard
	
	var statsAffected = effectData.get("stats_affected", [])
	
	for stat in statsAffected:
		match stat:
			"attack":
				hostCard.cardAttack += statBoostAmount
			"health":
				hostCard.cardHealth += statBoostAmount
	
	hostCard.updateCardVisuals()
	print("StatAugmentation: Applied +", statBoostAmount, " to ", statsAffected, " for ", hostCard.cardName)
