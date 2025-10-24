#Add to autoload
extends Node

var cardScene = preload("res://src/card/card.tscn")
var characterCardScene = preload("res://src/card/character_card.tscn")

func _ready():
	if CardDataBuilder.cards.is_empty():
		await CardDataBuilder.ready

func createCard(cardId) -> Node2D:
	var cardData = CardDataBuilder.cards.get(cardId, null)
	if cardData == null:
		push_error("Failed to load card, could not find " + cardId + "in the card dictionary")
		return null
	
	var cardInstance: Node2D
	if cardData.type == "player":
		cardInstance = characterCardScene.instantiate()
	else:
		cardInstance = cardScene.instantiate()
	
	cardInstance.initialiseCard(cardData)
	return cardInstance
