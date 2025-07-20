#📡 Brodcasts changes in the game that can trigger effects 📡

extends Node

enum EventType {
	SLOT_FILLED,
	SLOT_EMPTIED,
	CARD_PLAYED,
	HEALTH_CHANGED,
	BOARD_CHANGED,
}

static var subscribers: Dictionary = {}

static func brodcastEvent(event: EventBrodcast):
	var eventType = event.type
	print("🔥 Broadcasting event: ", EventType.keys()[eventType])
	
	if !subscribers.has(eventType):
		print("   No subscribers for this event type")
		return
	
	print("   Found ", subscribers[eventType].size(), " subscribers")
	
	for listener in subscribers[eventType]:
		if is_instance_valid(listener):
			listener.onEvent(event)

static func subscribeToBrodcast(listener: Node, eventTypes: Array[EventType]):
	for eventType in eventTypes:
		if !subscribers.has(eventType):
			subscribers[eventType] = []
		
		if !subscribers[eventType].has(listener):
			subscribers[eventType].append(listener)

static func unsubscribersToBrodcast(listener: Node):
	for eventType in subscribers:
		if subscribers[eventType].has(listener):
			subscribers[eventType].erase(listener)
