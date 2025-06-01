extends DeckModel
class_name JourneyDeck

signal journeyCardRevealed(card,slot)

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
	#this will maybe call a helper or a journey deck builder system for now hard coded
	var journeyCards = [# Mix of combat units with different strengths
				"M_0001", "M_0002", "M_0003", "M_0003", "M_0004", "M_0001", "M_0002", "M_0004",
				# Locations spaced out
				"M_0005", "M_0006", "M_0005", "M_0006",
				# Buffs spaced out to enhance player
				"M_0007", "M_0008", "M_0009", "M_0007", "M_0008", "M_0009",
				# More units with buffs interspersed
				"M_0001", "M_0007", "M_0002", "M_0008", "M_0003", "M_0009", "M_0004",
				# End of journey with more challenging units
				"M_0002", "M_0001", "M_0004", "M_0002", "M_0001", "M_0004"
			]
	initaliseDeck(journeyCards)

func fillEmptySlots():
	print("1")
	print("boardNode = ", boardNode)
	print("boardNode class = ", boardNode.get_class())
	print("Has getEmptySlots method: ", boardNode.has_method("getEmptySlots"))
	
	if !boardNode || !boardNode.has_method("getEmptySlots"):
		push_error("JourneyDeck: Board not found or the getEmptySlots function's not there ?")
		return

	var emptySlots = boardNode.getEmptySlots()
	print("Found " + str(emptySlots.size()) + " empty slots to fill")
	var delayBetweenCards = 0.04
	
	for slot in emptySlots:
		if cards.is_empty():
			break
		
		var card = drawCard()
		if card:
			placeCardInSlot(card, slot)
			await get_tree().create_timer(delayBetweenCards).timeout

func placeCardInSlot(card, slot):
	card.setCardState(card.cardState.IN_SLOT)
	
	if card.get_node("CardBack").visible && !card.get_node("CardFace").visible:
		card.flipCard()
	
	add_child(card)
	card.global_position = global_position
	
	var tween = create_tween()
	tween.tween_property(card, "global_position", slot.global_position, 0.3)
	tween.parallel().tween_property(card, "rotation", slot.rotation, 0.3)
	tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.2)
	
	slot.setCurrentCard(card)
	
	emit_signal("journeyCardRevealed", card, slot)
	GlobalSignalBus.emit_signal("slotFilled", slot, card)

func revealTopCard(slot):
	if cards.is_empty():
		emit_signal("deckEmptied")
		return null
		
	var card = drawCard()
	if card && slot:
		placeCardInSlot(card, slot)
	
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
