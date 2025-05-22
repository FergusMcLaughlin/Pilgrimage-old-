extends Node

var characterCardNameList = []
var getCardsOfTypeFromDictionaryHelper: GetCardsOfTypeFromDictionaryHelper
var characterCards = []
#var focusedCharacter
#var selectedCharacter

func _ready():
	createCharacterCards()


func createCharacterCards():
	getCardsOfTypeFromDictionaryHelper = GetCardsOfTypeFromDictionaryHelper.new()
	characterCardNameList.append_array(getCardsOfTypeFromDictionaryHelper.getCardsOfType("player"))
	
	for cardId in characterCardNameList:
		var cardInstance = CreateCard.createCard(cardId)
		if cardInstance:
			cardInstance.flipCard()
			add_child(cardInstance)
			characterCards.append(cardInstance)


# go to scene tree, get all cards that have been created, orgonise them into a grid format similar to the card grid

#func focusedCharacter()
#when the player clicks the card set it to focused

#func SelectedCharacter()
#when the player clicks the card set it to selected
