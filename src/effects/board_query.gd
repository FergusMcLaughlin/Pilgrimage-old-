class_name BoardQuery

static func executeQuery(queryData: Dictionary):
	var queryType = queryData.get("query", "")
	var filter = queryData.get("filter", {})
	
	match queryType:
		"count":
			return queryCount(filter)
		"adjacent":
			return queryAdjacent(filter)
		"pattern":
			return queryPattern(filter)
		"totalBreakdown":
			return queryTotalBreakdown(filter)
		_:
			push_warning("BoardQuery: Unknown query type: " + queryType)
			return null

#Query Types________________________________________________________________________________________

static func queryCount(filter: Dictionary):
	var board = GetCurrentBoardHelper.getCurrentBoard()
	if !board:
		return 0
	
	var count = 0
	var occupiedSlots = board.getOccupiedSlots()
	
	for slot in occupiedSlots:
		var card = slot.currentCard
		if GetCurrentBoardHelper.matchesFilter(card, filter):
			count += 1
			
	return count

#add these later
static func queryAdjacent(filter: Dictionary):
	pass

static func queryPattern(filter: Dictionary):
	pass

static func queryTotalBreakdown(filter: Dictionary):
	var board = GetCurrentBoardHelper.getCurrentBoard()
	if !board:
		return {}
	
	var breakdown = {}
	var occupiedSlots = board.getOccupiedSlots()
	
	for slot in occupiedSlots:
		var card = slot.currentCard
		var cardType = card.cardType
		
		if !breakdown.has(cardType):
			breakdown[cardType] = 0
		breakdown[cardType] += 1
	
	return breakdown
			
