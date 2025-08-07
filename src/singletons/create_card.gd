#Add to autoload
extends Node

var cardScene = preload("res://src/card/card.tscn")
var characterCardScene = preload("res://src/card/character_card.tscn")

func _ready():
	if CardDictionaryJsonLoader.cardData.is_empty():
		await CardDictionaryJsonLoader.ready

func createCard(cardId) -> Node2D:
	var cardInstance
	if !CardDictionaryJsonLoader.cardData.has(cardId):
		push_error("Failed to load card, could not find " + cardId + "in the card dictionary")
		return null
	
	var cardData = CardDictionaryJsonLoader.cardData[cardId]
	
	if cardData.has("isPlayer") and cardData["isPlayer"] == true:
		cardInstance = characterCardScene.instantiate()
	else:
		cardInstance = cardScene.instantiate()
		
	
	cardInstance.initialiseCard(cardData)
	return cardInstance
