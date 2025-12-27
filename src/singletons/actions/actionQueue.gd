extends Node

signal actionEnqueued(action: Dictionary)
signal actionPopped(action: Dictionary)
signal queueCleared()

var _queue: Array[Dictionary] = []

func enqueueAction(action: Dictionary) -> void:
	if action.is_empty():
		push_warning("ActionQueue cannot enqueue an empty action so it is ignored")
		return
	if !action.has("type") or str(action.get("type", "")).strip_edges() == "":
		push_warning("ActionQueue missing or blank 'type' %s" % [action])
		return
	
	_queue.append(action)
	emit_signal("actionEnqueued", action)

func isQueueEmpty() -> bool:
	return !_queue.is_empty()

func popNextAction() -> Dictionary:
	if _queue.is_empty():
		return {}
	var action = _queue.pop_front()
	emit_signal("actionPopped", action)
	return action

func queryNextAction() -> Dictionary:
	if _queue.is_empty():
		return {}
	return _queue[0]

func clearQueue():
	_queue.clear()
	emit_signal("queueCleared")

func getQueueSize() -> int:
	return _queue.size()

func getCopyOfActionQueue() -> Array[Dictionary]:
	return _queue.duplicate(true)
	
