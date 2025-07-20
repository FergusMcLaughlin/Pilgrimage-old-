class_name EffectCommand

var execute: Callable
var undo: Callable
var metadata: Dictionary

func _init(executeFunc: Callable, undoFunc: Callable = Callable(), meta: Dictionary = {}):
	execute = executeFunc
	undo = undoFunc
	metadata = meta

static func statBoost(target: Node2D, stat: String, amount: int):#this
	var statProperty = "card" + stat.capitalize()  # "attack" -> "cardAttack"
	
	return EffectCommand.new(
		func():
			var currentValue = target.get(statProperty)
			target.set(statProperty, currentValue + amount)
			if target.has_method("updateCardVisuals"):
				target.updateCardVisuals()
			print("✨ Boosted ", target.cardName, " ", stat, " by ", amount, " (now ", target.get(statProperty), ")"),
		func():
			var currentValue = target.get(statProperty)
			target.set(statProperty, currentValue - amount)
			if target.has_method("updateCardVisuals"):
				target.updateCardVisuals()
			print("↩️ Removed boost from ", target.cardName, " ", stat, " by ", amount),
		{"type": "stat_boost", "target": target, "stat": stat, "amount": amount}
	)

static func drawCard(player: Node, count: int = 1) -> EffectCommand:
	return EffectCommand.new(
		func():
			for i in count:
				if player.has_method("drawCard"):
					player.drawCard()
			print("🃏 Drew ", count, " card(s)"),
		Callable(), # No undo for draw
		{"type": "draw_card", "player": player, "count": count}
	)
