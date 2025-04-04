extends Node2D

signal cardDrawn(card)
signal deckEmptied(deck)
signal deckShuffled(deck)
signal deckClicked(deck)

const cardDrawSpeed = 0.2
var deck = ["0002", "0002", "0002", "0002", "0002", "0002", "0002", "0002" ]

func _ready():
	$Area2D.collision_layer = GameConstants.LAYER_DECK
	$Area2D.input_event.connect(onInputEvent)
	shuffle()
	updateDeckDisplay()

func shuffle():
	deck.shuffle()
	emit_signal("deckShuffled", self)
	updateDeckDisplay()

func updateDeckDisplay():
	$RichTextLabel.text = str(deck.size())
	
	if deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$DeckSprite.visible = false
		$RichTextLabel.visible = false
		emit_signal("deckEmptied", self)

func drawCard():
	if deck.size() == 0:
		print("Deck is empty, cannot draw card!")
		return null
	
	var cardId = deck[0]
	deck.erase(cardId)
	updateDeckDisplay()
	
	var newCard = CreateCard.createCard(cardId)
	
	if !newCard:
		print("Failed to create card with ID: %s" % cardId)
		return null
		
	get_parent().add_child(newCard)
	newCard.name = "Card" + cardId
		
	var handNode = get_parent().get_node_or_null("Hand")
	if handNode:
		handNode.addCardToHand(newCard)
	else:
		print("Warning: No 'Hand' node found!")
		
	newCard.flipCard()
		
	emit_signal("cardDrawn", newCard)
	return newCard

func onInputEvent(_viewport, event, _shapeIdx):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		print("Deck clicked!")
		emit_signal("deckClicked", self)
		drawCard()
