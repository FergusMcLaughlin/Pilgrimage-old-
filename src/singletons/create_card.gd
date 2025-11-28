#Add to autoload
extends Node

var cardScene = preload("res://src/card/card.tscn")
var characterCardScene = preload("res://src/card/character_card.tscn")

func _ready():
	if CardDictionaryJsonLoader.cardDictionaryData.is_empty():
		await CardDictionaryJsonLoader.ready

func createCard(cardId) -> Node2D:
	var createCardData: CardData = CardDataRegistry.getCardData(cardId)
	if createCardData == null:
		push_error("Failed to load card, could not find %s in CardDataRegistry" % cardId)
		return null
	
	var cardInstance: Node2D
	if createCardData.cardIsPlayer:
		cardInstance = characterCardScene.instantiate()
	else:
		cardInstance = cardScene.instantiate()
	
	cardInstance.initialiseCard(createCardData)
	return cardInstance
