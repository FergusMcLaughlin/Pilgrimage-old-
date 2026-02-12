extends Node
class_name Grid

@export var rows:int = 3
@export var columns:int = 3
@export var cellSize: Vector2 = Vector2(192, 179) #move this into constants maybe ?
@export var slotScene: PackedScene

var slots = []

func _ready():
	createGrid()
#	GlobalSignalBus.connect("slotFilled", onSlotFilled)
#	GlobalSignalBus.connect("slotEmptied", onSlotEmptied)

func createGrid():
	#remove existing
	for child in get_children():
		if child.is_in_group("cardSlot"):
			child.queue_free()
			
	slots.clear()
	
	for row in range(rows):
		var rowSlots = []
		for col in range(columns):
			var slot = slotScene.instantiate()
			slot.position = Vector2(
				(col - (columns-1)/2.0) * cellSize.x,
				(row - (rows-1)/2.0) * cellSize.y
			)
			slot.coordinates = Vector2(col, row)
			slot.name = "CardSlot_" + str(col) + "_" + str(row)
			add_child(slot)
			slot.add_to_group("cardSlot")
			rowSlots.append(slot)
			
		slots.append(rowSlots)

func getSlotAt(coordinates: Vector2):
	if coordinates.x < 0 || coordinates.x >= columns || coordinates.y < 0 || coordinates.y >= rows:
		return null
	return slots[coordinates.y][coordinates.x]

func getEmptySlots():
	var empty = []
	for row in slots:
		for slot in row:
			if !slot.cardInSlot:
				empty.append(slot)
	return empty

func getOccupiedSlots():
	var occupied = []
	for row in slots:
		for slot in row:
			if slot.cardInSlot:
				occupied.append(slot)
	return occupied

func getAllNeighbours(slot):
	var neighbours = []
	var coordinates = slot.coordinates
	
	var directions = []
	for x in range(-1,2):
		for y in range(-1,2):
			if x==0 && y==0:
				continue
			directions.append(Vector2(x,y))
	
	for dir in directions:
		var neighbourCoordinates = coordinates + dir
		var neighbour = getSlotAt(neighbourCoordinates)
		if neighbour:
			neighbours.append(neighbour)
	
	return neighbours

func getCardinalNeighbours(slot):
	var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	var cardinalNeighbours = []
	for direction in directions:
		var neighbour = getSlotAt(slot.coordinates + direction)
		if neighbour: 
			cardinalNeighbours.append(neighbour)
	return cardinalNeighbours

func getCenterSlot():
	var centerRow = int(floor(rows / 2))
	var centerCol = int(floor(columns / 2))
	
	var centerSlotPosition = Vector2(centerCol, centerRow)
	var centerSlot = getSlotAt(centerSlotPosition) 
	
	return centerSlot

func getSlotAtMousePosition(position:Vector2) -> CardSlot:
	var spaceState = get_viewport().world_2d.direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collision_mask = GameConstants.LAYER_SLOT
	query.collide_with_areas = true
	
	var result = spaceState.intersect_point(query)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func onSlotFilled(slot, card):
	pass

func onSlotEmptied(slot):
	pass
