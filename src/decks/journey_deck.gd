extends DeckModel
class_name JourneyDeck

signal journeyCardRevealed(card, slot)

@export var boardNodePath: NodePath
@export var autoFillBoardOnEmpty: bool = true

var boardNode

func _ready():
	super._ready()

	if !boardNodePath.is_empty():
		boardNode = get_node(boardNodePath)
	else:
		boardNode = get_node_or_null("../board")
		if !boardNode:
			push_error("JourneyDeck: Cannot find the board node")

func initialiseJourneyDeck():
	var journeyCards = [
		"M_0001", "M_0002", "M_0003", "M_0003", "M_0004", "M_0001", "M_0002", "M_0004",
		"M_0005", "M_0006", "M_0005", "M_0006", "M_0005", "M_0006", "M_0005", "M_0006", "M_0005", "M_0006", "M_0005", "M_0006",
		"M_0007", "M_0008", "M_0009", "M_0007", "M_0008", "M_0009",
		"M_0001", "M_0007", "M_0002", "M_0008", "M_0003", "M_0009", "M_0004",
		"M_0002", "M_0001", "M_0004", "M_0002", "M_0001", "M_0004"
	]
	initaliseDeck(journeyCards)

func fillEmptySlots():
	if !boardNode || !boardNode.has_method("getEmptySlots"):
		push_error("JourneyDeck: Board not found or getEmptySlots missing")
		return

	var emptySlots = boardNode.getEmptySlots()
	var delayBetweenCards = 0.04

	for slot in emptySlots:
		if cards.is_empty():
			break

		var card = drawCard()
		if card:
			_requestRevealCard(card, slot)
			await get_tree().create_timer(delayBetweenCards).timeout


func _requestRevealCard(card: Node2D, slot: Node) -> void:
	ActionQueue.enqueueAction({
		"type": ActionTypes.REVEAL_CARD,
		"source": self,     # the deck
		"target": slot,
		"data": {
			"card": card
		}
	})

func revealTopCard(slot):
	if cards.is_empty():
		emit_signal("deckEmptied")
		return null

	var card = drawCard()
	if card && slot:
		_requestRevealCard(card, slot)

	return card

func updateDeckDisplay():
	super.updateDeckDisplay()

func onDeckInputEvent(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		GlobalSignalBus.emit_signal("deckClicked", self)
		if boardNode && boardNode.has_method("getEmptySlots"):
			var emptySlots = boardNode.getEmptySlots()
			if !emptySlots.is_empty():
				revealTopCard(emptySlots[0])
