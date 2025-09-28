extends Control

@onready var text_label: RichTextLabel = $RichTextLabel

func _ready() -> void:
	text_label.bbcode_enabled = true
	set_process(true)

func _process(_delta: float) -> void:
	# Get the autoload by name (you said it's called TaskQ)
	var tq = get_node_or_null("/root/TaskQ")
	if tq == null:
		text_label.text = "[b]TaskQ autoload not found[/b]\nCheck Project Settings → Autoload."
		return

	var lines: Array[String] = []
	lines.append("[b]TASK QUEUE DEBUG[/b]")
	lines.append("Executing: %s" % tq.isExicuting)            # keep your spelling, or rename everywhere
	lines.append("Current timer: %.2f" % tq.taskTimer)
	lines.append("")

	if tq.isExicuting:
		lines.append("[color=yellow]>> %s[/color]" % tq.currentTask.get("label", "(unnamed)"))
		# show remaining delay on current task if any
		if tq.currentTask.get("delay", 0.0) > 0.0:
			lines.append("   waiting: %.2fs" % max(tq.taskTimer, 0.0))

	if tq.taskQueue.is_empty():
		lines.append("(queue empty)")
	else:
		lines.append("Pending tasks:")
		for i in tq.taskQueue.size():
			var task: Dictionary = tq.taskQueue[i]
			lines.append("  #%d: %s (delay=%.2f)" % [i, task.get("label",""), task.get("delay",0.0)])

	text_label.text = "\n".join(lines)
