extends Node

const PLAY_CARD = "playCard"
const REVEAL_CARD = "revealCard"
const MODIFY_STATS = "modifyStats"
const DESTROY_CARD = "destroyCard"

static func isBoardChanged(actionType: String) -> bool:
	return actionType in [
		PLAY_CARD,
		REVEAL_CARD,
		DESTROY_CARD
	]

static func isStatChanged(actionType: String) -> bool:
	return actionType in [
		MODIFY_STATS
	]

static func shouldTriggerEffects(actionType: String) -> bool:
	return isBoardChanged(actionType) || isStatChanged(actionType)

static func isValid(actionType: String) -> bool:
	return actionType in [
		PLAY_CARD,
		REVEAL_CARD,
		DESTROY_CARD,
		MODIFY_STATS
	]

static func assert_valid(actionType: String) -> void:
	if !isValid(actionType):
		push_warning("Unknown ActionType: %s" % actionType)
