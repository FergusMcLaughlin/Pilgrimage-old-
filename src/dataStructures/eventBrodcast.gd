class_name EventBrodcast

var type: GameEventsBrodcaster.EventType
var source: Node
var target: Node
var data: Dictionary

func _init(eventType: GameEventsBrodcaster.EventType, sourceNode: Node = null, targetNode: Node = null, eventData: Dictionary = {}):
	type = eventType
	source = sourceNode
	target = targetNode
	data = eventData
