extends Node
class_name BoardController

@export var gridPath: NodePath
@onready var grid: Grid = get_node(gridPath)

func onCardPlayed():
	updateBoardState()

func onCardDragEnded(card, dropPosition):
	var targetSlot = grid.getSlotAtMousePosition(dropPosition)
	if targetSlot && !targetSlot.cardInSlot:
		if targetSlot.canAcceptCard(card):
			return
		else:
			GlobalSignalBus.emitCardPlacementInvalid(card, targetSlot)

func placeCardInSlot(card, slot) -> void:
	if slot == null:
		return
	
	if !slot.canAcceptCard(card):
		return
	
	slot.setCurrentCard(card)
	GlobalSignalBus.emitCardPlayed(card,slot)
	GlobalSignalBus.emitBoardStateChanged()

func updateBoardState():
	GlobalSignalBus.emitBoardStateChanged()

func clearBoard():
	for row in grid.slots:
		for slot in row:
			if slot.currentCard:
				slot.clearSlot()
