#Add to autoload
extends Node

var cardScene = preload("res://src/card/card.tscn")

func _ready():
	if CardDictionaryJsonLoader.cardData.is_empty():
		await CardDictionaryJsonLoader.ready

func createCard(cardName) -> Node2D:
	if !CardDictionaryJsonLoader.cardData.has(cardName):
		push_error("Failed to load card, could not find " + cardName + "in the card dictionary")
		return null
	
	var cardData = CardDictionaryJsonLoader.cardData[cardName]
	var cardInstance = cardScene.instantiate()
	
	cardInstance.initialiseCard(cardData)
	return cardInstance
