extends Node
class_name Grid

@export var rows:int = 3
@export var columns:int = 3
@export var cellSize: Vector2 = Vector2(192, 179) #move this into constants maybe ?
@export var slotScene: PackedScene

var slots = []

func _ready():
	createGrid()

func createGrid():
	#remove existing
	for child in get_children():
		if child.is_in_group("cardSlot"):
			child.queue_free()
	#new grid
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
			slot.add_to_group("cardSlots")
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

func getNeighbours(slot):
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

func onSlotFilled(slot, card):
	pass

func onSlotEmptied(slot):
	pass
