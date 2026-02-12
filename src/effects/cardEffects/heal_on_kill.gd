class_name HealOnKill

const DEFAULT_TRIGGER := ActionTypes.DESTROY_CARD

var hostCard: Node2D
var trigger: String

func _init(card: Node2D, effectData: EffectData):
	hostCard = card
	trigger = effectData.effectTrigger if effectData.effectTrigger != "" else DEFAULT_TRIGGER

func onAction(action: Dictionary, when: String) -> void:
	if when != "pre":
		return

	var actionType := str(action.get("type", ""))
	if actionType != ActionTypes.DESTROY_CARD:
		return
		
	var attacker: Node2D = action.get("source", null)
	var destroyed: Node2D = action.get("target", null)
		
	if attacker == null || destroyed == null:
		return
	
	if destroyed != hostCard:
		return
	
	apply(attacker, destroyed)

func apply(attacker: Node2D, destroyed: Node2D):
	if !is_instance_valid(attacker) || !is_instance_valid(destroyed):
		push_warning("Heal.apply: destroyed or destroyer is not valid.")
		return
	
	var buffHealAmount = int(destroyed.cardBaseHealth)
	var newHealth = int(attacker.cardHealth) + buffHealAmount
	
	ActionQueue.enqueueAction(
		ActionTypes.make(
			ActionTypes.MODIFY_STATS,
			hostCard,
			attacker,
			{"health": newHealth}
			)
		)
