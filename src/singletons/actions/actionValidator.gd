extends Node

const PLAY_CARD = "play_card"
const REVEAL_CARD = "reveal_card"
const MODIFY_STATS = "modify_stats"
const DESTROY_CARD = "destroy_card"

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
