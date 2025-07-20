extends Node

var commandHistory: Array[Array] = []
var currentBatch: Array[EffectCommand] = []
var isProcessing: bool = false
#swap to global
signal batchStarted
signal batchComplete
signal commandExecuted(command: EffectCommand)

func _ready():
	pass

func batch(commands: Array[EffectCommand]):
	if commands.is_empty():
		return
	
	currentBatch.append_array(commands)
	
	if !isProcessing:
		call_deferred("processBatch")

func processBatch():
	if currentBatch.is_empty() || isProcessing:
		return
	
	isProcessing = true
	emit_signal("batchStarted")
	
	GameConstants.interactionsAllowed = false
	
	var batch = currentBatch.duplicate()
	currentBatch.clear()
	
	print("⚡ EXECUTING ", batch.size(), " COMMANDS:")
	
	for command in batch:
		command.execute.call()
		emit_signal("commandExecuted", command)
	
	commandHistory.append(batch)
	
	GameConstants.interactionsAllowed = true
	isProcessing = false
	emit_signal("batchCompleted")

func undo():
	if commandHistory.is_empty():
		return
	
	var lastBatch = commandHistory.pop_back()
	
	for i in range(lastBatch.size() - 1, -1, -1):
		if lastBatch[i].undo.is_valid():
			lastBatch[i].undo.call()
