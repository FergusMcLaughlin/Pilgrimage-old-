#Add to autoload
extends Node

var cardData = {}
var effectData = {}
var cardDictionaryPath = "res://data/card_dictionary.json"
var effectDictionaryPath = "res://data/effect_dictionary.json"


func _ready():
	cardData = loadDictionaryFromFile(cardDictionaryPath)
	effectData = loadDictionaryFromFile(effectDictionaryPath)

func loadDictionaryFromFile(filepath):
	if FileAccess.file_exists(filepath):
		var dataFile = FileAccess.open(filepath, FileAccess.READ)
		var parsedResults = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResults is Dictionary:
			return parsedResults
		else:
			push_error("File cant be read")
	else:
		push_error("File donsen't exist")
