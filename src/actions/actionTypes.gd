extends Node
class_name ActionTypes

const PLAY_CARD := "play_card"
const REVEAL_CARD := "reveal_card"
const SPAWN_CARD := "spawn_card"
const MODIFY_STATS := "modify_stats"
const DEAL_DAMAGE := "deal_damage"
const DRAW_CARD := "draw_card"
const DESTROY_CARD := "destroy_card"

static func make(type: String, source = null, target = null, data: Dictionary = {}) -> Dictionary:
	return {
		"type": type,
		"source": source,
		"target": target,
		"data": data
	}

static func isValid(action: Dictionary) -> bool:
	return action.has("type") && (action["type"] is String) && action["type"] != ""
