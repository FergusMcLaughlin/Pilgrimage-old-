class_name ResolveActionsHelper

static func resolveTarget(targetType: String, queryResult = null, sourceCard = null):
	match targetType:
		"self":
			return sourceCard
		"query_result":
			if queryResult is Array && !queryResult.is_empty():
				return queryResult[0]
			return queryResult
		"player":
			return GetCurrentBoardHelper.findCardByFilter({"type": "player"})
		_:
			return null

static func resolveTargets(targetType: String, queryResult = null, sourceCard = null):
	match targetType:
		"query_result":
			if queryResult is Array:
				return queryResult
			elif queryResult:
				return [queryResult]
			return []
		"pattern_cards":
			if queryResult is Dictionary && queryResult.has("cards"):
				return queryResult["cards"]
			return []
		_:
			var single = resolveTarget(targetType, queryResult, sourceCard)
			return [single] if single else []

static func calculateAmount(actionData: Dictionary, queryResult = null):
	var base = actionData.get("amount", 1)
	var perResult = actionData.get("per_result", false)
	var bonus = actionData.get("bonus", 0)
	
	var result = base
	if perResult && queryResult is int:
		result *= queryResult
	elif  perResult&& queryResult is Array:
		result *= queryResult.size()
	
	return result + bonus


static func resolveSpawnLocation(location: String):
	var board = GetCurrentBoardHelper.getCurrentBoard()
	if !board:
		return null
	
	match location:
		"random_empty":
			var emptySlots = board.getEmptySlots()
			if !emptySlots.is_empty():
				return emptySlots[randi() % emptySlots.size()]
		"center":
			return board.getCenterSlot()
		_:
			return null
	
	return null

static func resolveDestination(destination: String, sourceCard):
	match destination:
		"adjacent_empty":
			pass
		"random_empty":
			return resolveSpawnLocation("random_empty")
		_:
			return null
	
	return null
