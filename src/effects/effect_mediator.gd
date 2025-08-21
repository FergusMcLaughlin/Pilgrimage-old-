extends Node

var listeners = []
var effects = []

#Signals
signal effect_signal_card_played(card)

func _ready():
	effect_signal_card_played.connect(checkEffects)

func addListner(card, trigger):
	cleanUpListners()
	listeners.append({"card" : card, "trigger" : trigger})
	print("added " + card.cardName + " to listners, with trigger " + trigger)
	printListeners()

func removeListner(card):
	if listeners.has(card):
		listeners.erase(card)
		print(card.cardName, " earased from list of listners")

func cleanUpListners():
	var validListners = []
	for listner in listeners:
		var card = listner["card"]
		if is_instance_valid(card):
			validListners.append(listner)
		else:
			print("Cleaned up freed listener")
	
	listeners = validListners

func checkEffects(card):
	for listener in listeners:
		if listener.trigger == card.eventType: # is the listner's trigger the same as this event? (on_card_played(do effect) == on_card_played)
			listener.card.apply

#_______________________________________________________________________________
func addEffect(effectData):
	effects.append(effectData)
	print("queued effect " + effectData)

func exicuteEffect(effect):
	print("now exicuting : ", effect.type)

func processEffects():
	while effects.size() > 0:
		var effect = effects.pop_front()
		exicuteEffect(effect)


func printListeners():
	print("==========================================")
	print("CURRENT LISTENERS (", listeners.size(), " total):")
	if listeners.size() == 0:
		print("  (empty)")
	else:
		for i in range(listeners.size()):
			var listener_data = listeners[i]  # This is the dictionary
			var card = listener_data["card"]   # Get the card from the dictionary
			if is_instance_valid(card):
				print("  [", i, "] ", card.cardName, " (", listener_data["trigger"], ")")
			else:
				print("  [", i, "] FREED CARD")
	print("==========================================")
	
