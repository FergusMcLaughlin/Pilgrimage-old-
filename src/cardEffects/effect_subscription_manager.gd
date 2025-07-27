class_name EffectSubscriptionManager
extends Node

#Keeps track of who wants to be notified about what events
#Store callbacks, manage priorities, clean up dead references

var subscribers = {}

func subscribe(eventName: String, callback: Callable, priority: int, cardOwner):
	if !subscribers.has(eventName):
		subscribers[eventName] = []
	
	var subscription = {
		"callback": callback,
		"priority": priority,
		"cardOwner": cardOwner,
		"cardName": cardOwner.name if cardOwner else "Unknown"
	}
	
	subscribers[eventName].append(subscription)
	subscribers[eventName].sort_custom(func(a, b): return a.priority > b.priority) #check how this scales

func unsubscribe(eventName: String, callback: Callable):
	# the callback is being used to differenciate effects, thats it
	if !subscribers.has(eventName):
		return
	
	for i in range (subscribers[eventName].size() -1, -1, -1):
		if subscribers[eventName][i].callback == callback:
			subscribers[eventName].remove_at(i)
			break

func getSubscribers(eventName: String):
	return subscribers.get(eventName, [])

func clearCardsSubscriptions(card):
	for eventName in subscribers.key():
		for i in range (subscribers[eventName].size() -1, -1, -1):
			if subscribers[eventName][i].cardOwner == card:
				subscribers[eventName].remove_at(i)
