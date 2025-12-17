extends Node

var cardDataById: Dictionary = {}

func _ready() -> void:
	if(CardDictionaryJsonLoader.cardDictionaryData.is_empty()):
		await CardDictionaryJsonLoader.ready
	
	for cardId in CardDictionaryJsonLoader.cardDictionaryData.keys():
		var rawDictionary: Dictionary = CardDictionaryJsonLoader.cardDictionaryData[cardId]
		var data: CardData = CardDataFactory.loadDictionary(rawDictionary)
		cardDataById[cardId] = data

func getCardData(cardId: String) -> CardData:
	if(!cardDataById.has(cardId)):
		push_error("CardDataRegistry: unknown card id %s" % cardId)
		return null
	return cardDataById[cardId]
