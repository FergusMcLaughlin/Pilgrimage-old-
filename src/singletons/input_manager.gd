extends Node2D

var cardHoverHelper = CardHoverHelper.new()

var cardBeingDragged = null
var draggingOffset = Vector2.ZERO
var hoveredObject = null

func _ready():
	GlobalSignalBus.connect("cardClicked", onCardClicked)
	GlobalSignalBus.connect("cardHovered", onCardHovered)
	GlobalSignalBus.connect("cardUnhovered", onCardUnhovered)

func _input(event):
	if cardBeingDragged:
		if event is InputEventMouseMotion:
			var newPosition = event.global_position + draggingOffset
			cardBeingDragged.global_position = newPosition
			
			GlobalSignalBus.emit_signal("cardDragging", cardBeingDragged, newPosition)
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			stopDraggingCard(event.global_position)

func onCardClicked(card):
	if cardBeingDragged != null:
		return
	if card.currentState != card.cardState.BEING_DRAGGED:
		startDraggingCard(card)

func onCardHovered(card):
	if cardBeingDragged:
		return
	cardHoverHelper.applyHoverEffect(card, true)
	hoveredObject = card

func onCardUnhovered(card):
	if cardBeingDragged == card:
		return
	cardHoverHelper.applyHoverEffect(card, false)
	if hoveredObject == card:
		hoveredObject = null

func startDraggingCard(card):
	cardBeingDragged = card
	var mousePosition = get_viewport().get_mouse_position()
	draggingOffset = card.global_position - mousePosition
	
	var oldState = card.currentState
	card.setCardState(card.cardState.BEING_DRAGGED)
	
	GlobalSignalBus.emit_signal("cardDragStarted", card)

func stopDraggingCard(position):
	if !cardBeingDragged:
		return
	
	var targetSlot = findDroppingTarget(position)
	
	if targetSlot and isCardSlotValid(cardBeingDragged, targetSlot):
		placeCardInSlot(cardBeingDragged, targetSlot)
	else:
		returnCardToHand(cardBeingDragged)
		
	GlobalSignalBus.emit_signal("cardDragEnded", cardBeingDragged, position)
	cardBeingDragged = null

func findDroppingTarget(position):
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collide_with_areas = true
	query.collision_mask = GameConstants.LAYER_SLOT
	
	var mouseHitDetector = get_viewport().world_2d.direct_space_state
	
	var result = mouseHitDetector.intersect_point(query)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func isCardSlotValid(card, slot):
	if slot.cardInSlot == true:
		return false
	if slot.has_method("canAcceptCard"):
		return slot.canAcceptCard(card)
	return true

func placeCardInSlot(card, slot):
	if !isCardSlotValid(card, slot):
		returnCardToHand(card)
		return
	
	card.setCardState(card.cardState.ON_BOARD)
	
	slot.setCurrentCard(card)
	
	GlobalSignalBus.emit_signal("cardPlayed", card, slot)


func returnCardToHand(card):
	card.setCardState(card.cardState.IN_HAND)
	
	if GlobalSignalBus.has_signal("cardReturnedToHand"):
		GlobalSignalBus.emit_signal("cardReturnedToHand", card)
