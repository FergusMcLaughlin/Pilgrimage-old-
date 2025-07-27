class_name EffectProcessor
extends Node

# Manages the timing and sequence of effect execution
#  Process effect phases, prevent infinite loops, queue effects

var isProcessing = false
var effectQueue = []

func processEffectChain(eventName: String, data: Dictionary, subscriptionManager: EffectSubscriptionManager):
#entry point for processing an effect
	if isProcessing: # quee for later if busy
		effectQueue.append({
			"event": eventName,
			"data": data
		})
		return
	
	isProcessing = true 
	
	processPhase(eventName + "_will", data, subscriptionManager)#Will happen
	processPhase(eventName + "_during", data, subscriptionManager)#Is happening
	processPhase(eventName + "_did", data, subscriptionManager)#Did happen
	
	isProcessing = false
	
	processQueue(subscriptionManager)

func processPhase(phaseName: String, data: Dictionary, subscriptionManager: EffectSubscriptionManager):#Process a specific phase of an effect
	var subscribers = subscriptionManager.getSubscribers(phaseName) #et all callbacks interested in this phase
	
	for subscription in subscribers:
		var subscriptionCallBack = subscription.callback
		if subscriptionCallBack == null || subscriptionCallBack.is_null() || !subscriptionCallBack.is_valid():
			push_error("Effect callback error: " + str(subscriptionCallBack))
		else:
			subscription.callback.call(data)

func processQueue(subscriptionManager: EffectSubscriptionManager): #Process any effects that were queued
	while !effectQueue.is_empty():
		var nextEffect = effectQueue.pop_front()
		processEffectChain(nextEffect.event, nextEffect.data, subscriptionManager)
