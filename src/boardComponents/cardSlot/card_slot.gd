extends Node2D
class_name CardSlot

@export var coordinates: Vector2 = Vector2.ZERO
@export var allowedCardTypes: Array[String] =[]

var cardInSlot = false
var currentCard = null

@onready var area = $Area2D
@onready var collisonShape = $Area2D/CollisionShape2D

func _ready():
	add_to_group("cardSlot")
	
	area.connect("mouseEntered", onArea2dMouseEntered)
	area.connect("mouseExited", onArea2dMouseExited)
	area.connect("inputEvent", onArea2dInputEvent)
	
	$Area2D.collision_layer = GameConstants.LAYER_SLOT
	$Area2D.collision_mask = 0

func setCurrentCard(card):
	currentCard = card
	cardInSlot = true
	
	card.setCardState(card.cardState.IN_SLOT)
	card.reparent(self, true)
	
	card.moveToPosition(global_position)
	
	GlobalSignalBus.emitSlotFilled(self, card)

func clearSlot():
	if currentCard != null and currentCard.has_method("cleanUpEffects"):
		currentCard.cleanUpEffects()
	
	currentCard = null
	cardInSlot = false
	GlobalSignalBus.emitSlotEmptied(self)

func canAcceptCard(card):
	if cardInSlot:
		return false
	if allowedCardTypes.is_empty():
		return true
	return card.type in allowedCardTypes

func onArea2dMouseEntered():
	GlobalSignalBus.emitSlotHovered(self)

func onArea2dMouseExited():
	GlobalSignalBus.emitSlotUnhovered(self)

func onArea2dInputEvent(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		GlobalSignalBus.emitSlotClicked(self)

func onCardDragStarted(card):
	pass
