extends Node

var listeners = []
var effects = []

func addListner(card, effect_instance):
	cleanUpListners()
	var effectTrigger = effect_instance.trigger
	listeners.append({"card": card, "effect": effect_instance, "trigger": effectTrigger})
	print("LISTENER ADDED:", card, " trigger=", effect_instance.trigger, " effect=", effect_instance)

func removeListner(card):
	for i in range(listeners.size()):
		if listeners[i]["card"] == card:
			listeners.remove_at(i)
			break

func cleanUpListners():
	var validListners = []
	for listner in listeners:
		var card = listner["card"]
		if is_instance_valid(card):
			validListners.append(listner)
		else:
			print("Cleaned up freed listener")
	
	listeners = validListners

func addEffect(effectDictionaryData):
	effects.append(effectDictionaryData)

func exicuteEffect(effect):
	print("now exicuting : ", effect.type)

func processEffects():
	while effects.size() > 0:
		var effect = effects.pop_front()
		exicuteEffect(effect)

func onActionPre(action: Dictionary) -> void:
	print("action pre")
	_dispatchAction(action, "pre")

func onActionPost(action: Dictionary) -> void:
	print("MEDIATOR post:", action, " listeners=", listeners.size())
	_dispatchAction(action, "post")

func _dispatchAction(action: Dictionary, when: String) -> void:
	cleanUpListners()
	var actionType := str(action.get("type", ""))

	for listener in listeners:
		var trigger := str(listener.get("trigger", ""))

		# card_played should fire when the board changes (play OR reveal)
		if trigger == "card_played" and actionType != ActionTypes.PLAY_CARD and actionType != ActionTypes.REVEAL_CARD:
			continue

		var effect = listener.get("effect", null)
		if is_instance_valid(effect) and effect.has_method("onAction"):
			effect.onAction(action, when)
