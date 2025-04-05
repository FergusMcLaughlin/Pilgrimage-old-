extends Node2D
class_name DeckModel

signal cardDrawn(card)
signal deckEmptied
signal deckShuffled

@export var deckTexture: Texture2D

@onready var deckSprite = $DeckSprite
@onready var cardsCountLabel = $RichTextLabel
@onready var collisionShape = $Area2D/CollisionShape2D

const cardDrawSpeed = 0.2
var cards = []

func _ready():
	if deckTexture:
		deckSprite.texture = deckTexture
	
	$Area2D.collision_layer = GameConstants.LAYER_DECK
	$Area2D.collision_mask = 0
	$Area2D.input_event.connect(onDeckInputEvent)
	
	shuffleDeck()
	updateDeckDisplay()

func initaliseDeck(cardIds):
	cards = cardIds.duplicate()
	shuffleDeck()
	updateDeckDisplay()

func shuffleDeck():
	if cards.size() > 1:
		cards.shuffle()
		emit_signal("deckShuffled")
	updateDeckDisplay()

func updateDeckDisplay():
	cardsCountLabel.text = str(cards.size())
	
	if cards.is_empty():
		collisionShape.disabled = true
		deckSprite.visible = false
		cardsCountLabel.visible = false
		emit_signal("deckEmptied")
	else:
		collisionShape.disabled = false
		deckSprite.visible = true
		cardsCountLabel.visible = true

func drawCard():
	if cards.is_empty():
		return null
	
	var cardId = cards[0]
	cards.erase(cardId)
	updateDeckDisplay()
	
	var newCard = CreateCard.createCard(cardId)
	if newCard:
		emit_signal("cardDrawn", newCard)
	return newCard

func addCardToTop(cardId):
	cards.push_front(cardId)
	updateDeckDisplay()

func addCardToBottom(cardId):
	cards.push_back(cardId)
	updateDeckDisplay()

func getDeckSize():
	return cards.size()

func onDeckInputEvent(_viewport, event, _shapeIdx):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("deckClicked", self)
