extends Node
class_name ActionTypes

const PLAY_CARD := "playCard"
const REVEAL_CARD := "revealCard"
const SPAWN_CARD := "spawnCard"
const MODIFY_STATS := "modifyStats"
const DEAL_DAMAGE := "dealDamage"
const DRAW_CARD := "drawCard"
const DESTROY_CARD := "destroyCard"

static func make(type: String, source = null, target = null, data: Dictionary = {}) -> Dictionary:
	return {
		"type": type,
		"source": source,
		"target": target,
		"data": data
	}

static func isValid(action: Dictionary) -> bool:
	return action.has("type") && (action["type"] is String) && action["type"] != ""
