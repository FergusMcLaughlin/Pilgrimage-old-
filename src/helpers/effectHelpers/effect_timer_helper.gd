class_name EffectTimerHelper

var timer: Timer
var currentBatch: int = 0
var batches: Array = []
var batchCallback: Callable

func _init(parent: Node):
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(onTimeout)
	parent.add_child(timer)

func startBatchSequence(effectBatches: Array, timePerBatch: float, callback: Callable):
	if effectBatches.is_empty():
		return
	
	batches = effectBatches
	batchCallback = callback
	currentBatch = 0
	
	GameConstants.interactionsAllowed = false
	timer.wait_time = timePerBatch
	timer.start()

func onTimeout():
	if currentBatch < batches.size():
		batchCallback.call(batches[currentBatch])
		currentBatch += 1
		
		if currentBatch < batches.size():
			timer.start()
		else:
			finishSequence()
	else:
		finishSequence()

func finishSequence():
	batches.clear()
	currentBatch = 0
	GameConstants.interactionsAllowed = true
	GlobalSignalBus.emit_signal("effectsFinished")
