class_name CardEffect

var effectName: String
var effectDescription: String
var hostCard: Node2D
var effectData: Dictionary

var boardQueryHelper: BoardQueryHelper

func _init(card: Node2D, data: Dictionary):
	hostCard = card
	effectData = data
	effectName = data.get("name", "Unknown Effect")
	effectDescription = data.get("description", "No description")

func shouldRunEffectCheck(triggerType: String, context: Dictionary) -> bool:
	if !is_instance_valid(hostCard):
		return false
	return false

func applyCardEffect(context: Dictionary) -> void:
	if !is_instance_valid(hostCard):
		return
	pass

func playEffectAnimation():
	pass

func isCardValid() -> bool:
	return is_instance_valid(hostCard)
