extends Node
class_name TaskQueue

signal taskStarted(label: String)
signal taskFinished(label: String)
signal queueIsEmpty()

var taskQueue: Array[Dictionary] = []
var isExicuting = false
var currentTask: Dictionary = {}
var taskTimer = 0.0

#when i come here with the problem of effects and timing, this is set up so an await cha be passed in for thing like that

func _process(delta: float) -> void:
	if !isExicuting:
		exicuteNextTask()
		return
	
	#delay stuff in here
	if currentTask.delay > 0.0:
		taskTimer -= delta
		if taskTimer > 0.0:
			return
		currentTask.delay =0.0
		exicuteCurrentTask()
		return

func enqueueTask(callable: Callable, args: Array =[], delay: float = 0.0, label: String = "" ) -> void:
	taskQueue.append({
		"callable": callable,
		"args": args,
		"delay": max(delay, 0.0),
		"label": label,
	})

func clear() -> void:
	taskQueue.clear()

func busy() -> bool:
	return isExicuting || taskQueue.size() > 0

func exicuteNextTask():
	if taskQueue.is_empty():
		emit_signal("queueIsEmpty")
		return
	
	currentTask = taskQueue.pop_front()
	isExicuting = true
	if currentTask.label != "":
		emit_signal("taskStarted", currentTask.label)
	
	if currentTask.delay > 0.0:
		taskTimer = currentTask.delay
		return
	
	exicuteCurrentTask()

func exicuteCurrentTask():
	await currentTask.callable.callv(currentTask.args)
	
	if currentTask.label != "":
		emit_signal("taskFinished", currentTask.label)
		
	isExicuting = false
	exicuteNextTask()
