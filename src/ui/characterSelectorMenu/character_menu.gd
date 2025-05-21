extends Node

var characterList = []
var getCardsOfTypeFromDictionaryHelper: GetCardsOfTypeFromDictionaryHelper
#var focusedCharacter
#var selectedCharacter

func _ready():
	getCardsOfTypeFromDictionaryHelper = GetCardsOfTypeFromDictionaryHelper.new()
	print(getCardsOfTypeFromDictionaryHelper.getCardsOfType("player"))


#func characterDictionaryToList(characterDictionary):
#loop through each card in the dictionary
#add all there Id's to the character list

#func createCharacterCards(characterList):
#for each item in the loop we are going to need to instanciate a new character card object
#in here we should create the card, alter it depending on values in the dictionary
#then we should add it to our character grid
#creates all cards in the scene tree

#func addCardsToGrid()
# go to scene tree, get all cards that have been created, orgonise them into a grid format similar to the card grid

#func focusedCharacter()
#when the player clicks the card set it to focused

#func SelectedCharacter()
#when the player clicks the card set it to selected
