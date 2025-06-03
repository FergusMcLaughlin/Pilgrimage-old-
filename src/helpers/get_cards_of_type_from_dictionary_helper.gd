class_name GetCardsOfTypeFromDictionaryHelper

func getCardsOfType(targetType: String):
	var cardsOfTypeList = []
	
	if !isTargetValid(targetType):
		return false
	
	if CardDictionaryJsonLoader.cardData.is_empty():
		push_error("ERROR: CardData is Empty.")
		return false
	
	for cardId in CardDictionaryJsonLoader.cardData.keys():
		var card = CardDictionaryJsonLoader.cardData[cardId]
		if card.has("type") and card["type"] == targetType:
			cardsOfTypeList.append(card["id"])
	
	if cardsOfTypeList.is_empty():
		push_error("ERROR: finding cards with correct type")
		return false
	
	return cardsOfTypeList

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
