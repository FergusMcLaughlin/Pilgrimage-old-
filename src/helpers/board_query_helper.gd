class_name BoardQueryHelper

static func getCurrentBoard():
	if GlobalSignalBus.currentBoard:
		return GlobalSignalBus.currentBoard
	
	push_error("BoardQueryHelper: No current board set in GlobalSignalBus")
	return null

static func countCardsOfType(cardType: String, cardName: String = "") -> int:
	var board = getCurrentBoard()
	if !board:
		return 0
	
	var count = 0
	var occupiedSlots = board.getOccupiedSlots()
	
	for slot in occupiedSlots:
		var card = slot.currentCard
		if card && card.cardType == cardType:
			if cardName.is_empty() || card.cardName == cardName: #look at this
				count += 1
	return count

#add stuff in here like check cards next, gett all cards ect ect
