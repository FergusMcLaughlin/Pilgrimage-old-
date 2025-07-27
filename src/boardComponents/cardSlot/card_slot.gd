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
	
	GlobalSignalBus.connect("cardDragStarted", onCardDragStarted)
	
	$Area2D.collision_layer = GameConstants.LAYER_SLOT
	$Area2D.collision_mask = 0

func setCurrentCard(card):
	print("setting card in slot to :" + str(card))
	currentCard = card
	cardInSlot = true
	

	if card != null:
		card.setCardState(card.cardState.IN_SLOT)
		card.reparent(self, true)
		var tween = create_tween()
		tween.tween_property(card, "global_position", global_position, 0.3)
		tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.2)
		
		if GlobalSignalBus.has_signal("slotFilled"):
			GlobalSignalBus.emit_signal("slotFilled", self, card)
		else:
			print("ERROR: slotFilled signal does not exist!")
			
	#debug
	CardEffectBus.card_played(card, self)

func clearSlot():
	currentCard = null
	cardInSlot = false
	
	GlobalSignalBus.emit_signal("slotEmptied", self)

func canAcceptCard(card):
	if cardInSlot:
		return false
	if allowedCardTypes.is_empty():
		return true
	return card.type in allowedCardTypes

func getGlobalSlotCenter():
	return global_position

func onArea2dMouseEntered():
	GlobalSignalBus.emit_signal("slotHovered", self)

func onArea2dMouseExited():
	GlobalSignalBus.emit_signal("slotUnhovered", self)

func onArea2dInputEvent(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		print("CardSlot: CLICKED - emitting slotClicked signal")
		GlobalSignalBus.emit_signal("slotClicked", self)

func onCardDragStarted(card):
	pass

#func onCardDragEnded(card, position):
	#var slotRect = Rect2(global_position - Vector2(collisonShape.shape.extents), collisonShape.shape.extents * 2)
	#if slotRect.has_point(position) and !cardInSlot:
		#if canAcceptCard(card):
				   #if !cardInSlot && canAcceptCard(card):
			## Maybe highlight the slot or play a sound
			#pass
