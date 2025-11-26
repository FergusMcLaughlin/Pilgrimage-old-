extends Node
class_name CardDataRegistry

var cardDataById: Dictionary = {}

func _ready() -> void:
	if(CardDictionaryJsonLoader.cardData.is_empty()):
		await CardDictionaryJsonLoader.ready
	
	for cardId in CardDictionaryJsonLoader.cardData.keys():
		var rawDictionary: Dictionary = CardDictionaryJsonLoader.cardData[cardId]
		var data: cardData = CardDataFactory.loadDictionary(rawDictionary)
		cardDataById[cardId] = data

func getCardData(cardId: String) -> cardData:
	if(!cardDataById.has(cardId)):
		push_error("CardDataRegistry: unknown card id %s" % cardId)
		return null
	return cardDataById[cardId]
