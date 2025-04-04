extends Node2D

var cardId: String
var cardName: String
var cardType: String
var cardHealth: int
var cardAttack: int
var cardImagePath: String

enum cardState {
	ON_BOARD,
	IN_DECK,
	IN_HAND,
	BEING_DRAGGED,
	IN_SLOT
}

var currentState: int = cardState.IN_DECK 

func _ready():
	$Area2D.connect("mouse_entered", Callable(self, "onCardAreaEntered"))
	$Area2D.connect("mouse_exited", Callable(self, "onCardAreaExited"))
	$Area2D.connect("input_event", Callable(self, "onCardAreaInputEvent"))
	$Area2D.collision_layer = GameConstants.LAYER_CARD
	$Area2D.collision_mask = 0

func initialiseCard (cardData):
	cardId = cardData["id"]
	cardName = cardData["name"]
	cardType = cardData["type"]
	cardHealth = cardData["health"]
	cardAttack = cardData["attack"]
	
	cardImagePath = str("res://assets/images/cards/" + cardName +".png")
	
	updateCardVisuals()

func updateCardVisuals ():
	$Name.text = cardName
	$Health.text = str(cardHealth)
	$Attack.text = str(cardAttack)
	
	var texture = load(cardImagePath)
	if texture:
		$CardFace.texture = texture
		$CardFace.scale = Vector2(0.1, 0.1)
	else: 
		push_error("Cant load card picture: " + cardImagePath)


func setCardState (newCardState):
	var oldState = currentState
	currentState = newCardState
	
	z_index = 1
	scale = Vector2(1.0, 1.0)
	
	match currentState:
		cardState.IN_DECK:
			print("card in deck")
			$Area2D.input_pickable = false
		cardState.IN_HAND:
			print("card in hand")
			$Area2D.input_pickable = true
		cardState.ON_BOARD:
			print("card on board")
			$Area2D.input_pickable = true
		cardState.BEING_DRAGGED:
			print("card being dragged")
			z_index = 10
			scale = Vector2(1.05, 1.05)
			$Area2D.input_pickable = false
		cardState.IN_SLOT:
			print("card in slot")
			$Area2D.input_pickable = false
	
	GlobalSignalBus.emit_signal("cardStateChanged", self, oldState, newCardState)

func flipCard ():
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 0, 0.15)
	tween.tween_callback(func():
		# Toggle visibility of front and back
		$CardFace.visible = !$CardFace.visible
		$CardBack.visible = !$CardBack.visible
		
		$Name.visible = !$Name.visible
		$Health.visible = 	!$Health.visible
		$Attack.visible = 	!$Attack.visible
		
		)
	tween.tween_property(self, "scale:x", 1, 0.15)
	GlobalSignalBus.emit_signal("cardFlipped", self)

func onCardAreaEntered():
	GlobalSignalBus.emit_signal("cardHovered", self)

func onCardAreaExited():
	GlobalSignalBus.emit_signal("cardUnhovered", self)

func onCardAreaInputEvent(_viewport,event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Card: Clicked detected, emitting cardClicked signal")
		GlobalSignalBus.emit_signal("cardClicked", self)
