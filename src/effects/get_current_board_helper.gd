class_name GetCurrentBoardHelper

static func getCurrentBoard():
	return GlobalSignalBus.currentBoard #This could cause issues

static func findCardByFilter(filter: Dictionary):
	if filter.has("type") && filter["type"] == "player":
		var board = getCurrentBoard()
		if !board:
			return null
		
		var occupiedSlots = board.getOccupiedSlots()
		for slot in occupiedSlots:
			var card = slot.currentCard
			if card && card.get("isPlayerCard") == true:
				return card
	
	return null

static func matchesFilter(card, filter: Dictionary):
	if !card:
		return false
	
	if filter.has("type") && card.cardType != filter ["type"]:
		return false
	
	if filter.has("name") && card.cardName != filter["name"]:
		return false
	
	return true
