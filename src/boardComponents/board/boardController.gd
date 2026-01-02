extends Node
class_name BoardController

@export var gridPath: NodePath
@onready var grid: Grid = get_node(gridPath)

var turnNumber = 0

func _ready():
	GlobalSignalBus.connect("cardPlayed", onCardPlayed)
	GlobalSignalBus.connect("cardDragEnded", onCardDragEnded)

func onCardPlayed():
	updateBoardState()

func onCardDragEnded(card, dropPosition):
	var targetSlot = getSlotAtPosition(dropPosition)
	if targetSlot && !targetSlot.cardInSlot:
		if targetSlot.canAcceptCard(card):
			# Do nothing. InputManager already enqueued PLAY_CARD.
			return
		else:
			if GlobalSignalBus.has_signal("cardPlacementInvalid"):
				GlobalSignalBus.emit_signal("cardPlacementInvalid", card, targetSlot)

func placeCardInSlot(card, slot):
	card.setCardState(card.cardState.ON_BOARD)
	
	var tween = create_tween()
	tween.tween_property(card,"global_position", slot.global_position, 0.3)
	tween.tween_property(card, "scale", Vector2(1.0,1.0), 0.2)
	
	slot.setCurrentCard(card)
	
	if GlobalSignalBus.has_signal("cardPlayed"):
		GlobalSignalBus.emit_signal("cardPlayed", card, slot)

func updateBoardState():
	GlobalSignalBus.emit_signal("boardStateChanged")

func getSlotAtPosition(position:Vector2) -> CardSlot:
	var spaceState = get_viewport().world_2d.direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collision_mask = GameConstants.LAYER_SLOT
	query.collide_with_areas = true
	
	var result = spaceState.intersect_point(query)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func clearBoard():
	for row in grid.slots:
		for slot in row:
			if slot.currentCard:
				slot.clearSlot()

func getOccupiedSlots():
	if !grid:
		push_error("grid is not linked to the board. check inspector")
	var occupied = []
	for row in grid.slots:
		for slot in row:
			if slot.cardInSlot:
				occupied.append(slot)
	return occupied

func getEmptySlots():
	if !grid:
		push_error("grid is not linked to the board. check inspector")
	var empty = []
	for row in grid.slots:
		for slot in row:
			if !slot.cardInSlot:
				empty.append(slot)
	return empty

func getCenterSlot():
	if !grid:
		push_error("grid is not linked to the board. check inspector")
	var centerRow = int(floor(grid.rows / 2))
	var centerCol = int(floor(grid.columns / 2))
	
	var centerSlotPosition = Vector2(centerCol, centerRow)
	var centerSlot = grid.getSlotAt(centerSlotPosition) 
	
	return centerSlot
