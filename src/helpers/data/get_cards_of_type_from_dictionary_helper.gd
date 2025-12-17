class_name GetCardsOfTypeFromDictionaryHelper

func getCardsOfType(targetType: String) -> Array[String]:
	if !isTargetValid(targetType):
		return []
	
	var results : Array[String] = []
	var cardRegistry = CardDataRegistry
	
	for cardId in cardRegistry.cardDataById.keys():
		var data: CardData = cardRegistry.cardDataById[cardId]
		if data.cardType == targetType:
			results.append(data.cardId)
			
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
