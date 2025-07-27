extends Node

#auto load for connecting all the effect's subsystems

var effectsProcessor
var effectSubscriptionManager
#var deathQueueHandler

func _ready():
#instancisate the helpers and then add the mas children to the scene tree
	effectsProcessor = EffectProcessor.new()
	effectSubscriptionManager = EffectSubscriptionManager.new()
	
	add_child(effectsProcessor)
	add_child(effectSubscriptionManager)

func subscribe(eventName: String, callback: Callable, prioity: int = 0, cardOwner = null):
	# this will delegate subscribing to the subscription manager
	effectSubscriptionManager.subscribe(eventName, callback, prioity, cardOwner)

func trigger(eventName: String, data: Dictionary = {}): # kicks off an event chain
	# this will delegate to the processor passing subscription manager for callbacks
	effectsProcessor.processEffectChain(eventName, data, effectSubscriptionManager)

func clear_card_effects(card): #Remove all subscriptions when card is destroyed
	#  Delegate cleanup to subscription manager
	effectSubscriptionManager.clearCardsSubscriptions(card)

#could include common tiggers as functions in here so i dont have to retype them(wont do this)
func card_played(card, slot):                  # Line 33: Helper for "card played" event
	trigger("card_played", {"card": card, "slot": slot})  # Line 34: Convert to generic trigger with specific data
