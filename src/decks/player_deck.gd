extends DeckModel
class_name PlayerDeck

signal cardDrawnToHand(card)

@export var handNodePath: NodePath

var handNode

func _ready():
	super._ready()
	
	if !handNodePath.is_empty():
		handNode = get_node(handNodePath)
	else:
		handNode = get_node_or_null("../Hand")
		if !handNode:
			push_error("PlayerDeck: Cannot find a hand node")

func initialiseFromPreset(presetName):
	var cards = loadDeckPreset(presetName)
	if cards:
		initaliseDeck(cards)
		print("Deck initialized with", cards.size(), "cards")
	else:
		push_error("Failed to load deck preset: " + presetName)

func loadDeckPreset(presetName):
	#ill need to add 2 scripts to deal with deck gen at some stage.
	var presets = {
		"test":["0001","0002","0003","0004","0001","0005"],
		"deck_2":[],
		"deck_3":[]
	}
	
	if presets.has(presetName):
		return presets[presetName]
	return null

func drawCardToHand():
	var card = drawCard()
	if card && handNode && handNode.has_method("addCardToHand"):
		handNode.addCardToHand(card)
		emit_signal("cardDrawnToHand", card)
	return card

func drawMultipleCardsToHand(count): #not used yet
	var drawnCards = []
	for i in range(count):
		var card = drawCardToHand()
		if card:
			drawnCards.append(card)
		else:
			break
	return drawnCards

func onDeckInputEvent(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		GlobalSignalBus.emit_signal("deckClicked", self)
		drawCardToHand()
