#Add to autoload
extends Node

var cardScene = preload("res://src/card/card.tscn")
var characterCardScene = preload("res://src/card/character_card.tscn")

func _ready():
	if DictionaryJsonLoader.cardData.is_empty():
		await DictionaryJsonLoader.ready

func createCard(cardId) -> Node2D:
	var cardInstance
	if !DictionaryJsonLoader.cardData.has(cardId):
		push_error("Failed to load card, could not find " + cardId + "in the card dictionary")
		return null
	
	var cardData = DictionaryJsonLoader.cardData[cardId]
	
	if cardData.has("isPlayer") and cardData["isPlayer"] == true:
		cardInstance = characterCardScene.instantiate()
	else:
		cardInstance = cardScene.instantiate()
	
	cardInstance.initialiseCard(cardData)
	return cardInstance
