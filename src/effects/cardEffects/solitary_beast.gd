class_name SolitaryBeast

const DEFAULT_TARGET_TYPE := "Woods"
const DEFAULT_ATTACK_PER_MATCH := 1
const DEFAULT_HEALTH_PER_MATCH := 1
const DEFAULT_TRIGGER := "card_played"

var hostCard: Node2D
var targetType: String
var attackPerMatch: int
var healthPerMatch: int
var trigger: String

func _init(card: Node2D, effectData: EffectData):
	hostCard = card
	var params := effectData.effectParameters
	var countConditions := params.get("count_condition", {}) as Dictionary
		
	targetType = String(countConditions.get("target", DEFAULT_TARGET_TYPE))
	attackPerMatch = int(params.get("attack_per_match", DEFAULT_ATTACK_PER_MATCH))
	healthPerMatch = int(params.get("health_per_match", DEFAULT_HEALTH_PER_MATCH))
	trigger = effectData.effectTrigger if effectData.effectTrigger != "" else DEFAULT_TRIGGER

func checkWoodsCardsOnBoard() -> int:
	var count = 0
	var slots = GameController.boardController.getOccupiedSlots()
	
	for slot in slots:
		var card = slot.currentCard
		if card != null && card.cardName == targetType:
			count += 1
	
	return count

func calculateStatsChange(woodsCount: int) -> Dictionary:
	var attackBonus = attackPerMatch * woodsCount
	var healthBonus = healthPerMatch * woodsCount
	return {
	"attack" : hostCard.cardBaseAttack + attackBonus,
	"health" : hostCard.cardBaseHealth + healthBonus
	}

func onAction(action: Dictionary, when: String) -> void:
	if when != "post":
		return
	var actionType := str(action.get("type", ""))

	# Decide what should trigger re-calc:
	if actionType != ActionTypes.PLAY_CARD && actionType != ActionTypes.REVEAL_CARD:
		return

	apply()

func apply():
	if not is_instance_valid(hostCard):
		push_warning("SolitaryBeast.apply: host card freed")
		return
	
	var woodsCount = checkWoodsCardsOnBoard()
	var adjusted = calculateStatsChange(woodsCount)
	
	ActionQueue.enqueueAction({
		"type": ActionTypes.MODIFY_STATS,
		"source": hostCard,
		"target":hostCard,
		"data": {
			"attack": adjusted["attack"],
			"health": adjusted["health"]
		}
	})
