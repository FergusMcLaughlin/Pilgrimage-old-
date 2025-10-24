class_name GetCardsOfTypeFromDictionaryHelper

func getCardsOfType(targetType: String):
	var results = []
	
	if !isTargetValid(targetType):
		return []
	
	if CardDataBuilder.cardData.is_empty():
		push_error("ERROR: CardData is Empty.")
		return []
	
	for cardId in CardDataBuilder.cardData.keys():
		var cardData = CardDataBuilder.cardData[cardId]
		if cardData.type == targetType:
			results.append(cardData.id)
	
	if results.is_empty():
		push_warning("ERROR: finding cards with correct type")
	
	return results

func isTargetValid(targetType: String):
	match targetType:
		"player":
			return true
		"unit":
			return true
		"location":
			return true
		"buff":
			return true
		_:
			push_error("ERROR: Unknown card type")
			return false
