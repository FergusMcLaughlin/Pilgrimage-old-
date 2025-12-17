class_name CardStatColourHelper

const STAT_COLOUR_NORMAL = Color.BLACK
const STAT_COLOUR_BUFFED = Color.DARK_GREEN
const STAT_COLOUR_DEBUFFED = Color.DARK_RED

static func updateStatColours(cardType: String, cardAttack: int, cardBaseAttack: int, cardHealth: int, cardBaseHealth: int, attackStat: CanvasItem, healthStat: CanvasItem):
	if cardType == "player":
		return
	
	if cardAttack > cardBaseAttack:
		attackStat.modulate = STAT_COLOUR_BUFFED 
	elif cardAttack < cardBaseAttack:
		attackStat.modulate = STAT_COLOUR_DEBUFFED 
	else:
		attackStat.modulate = STAT_COLOUR_NORMAL
	
	if cardHealth > cardBaseHealth:
		healthStat.modulate = STAT_COLOUR_BUFFED 
	elif cardHealth < cardBaseHealth:
		healthStat.modulate = STAT_COLOUR_DEBUFFED
	else:
		healthStat.modulate = STAT_COLOUR_NORMAL
