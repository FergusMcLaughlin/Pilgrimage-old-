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
	var data = effectData
	
	var params = effectData.parameters
	var countCond = params.get("count_condition", {}) as Dictionary
	
	targetType = String(countCond.get("target", DEFAULT_TARGET_TYPE))
	attackPerMatch = int(params.get("attack_per_match", DEFAULT_ATTACK_PER_MATCH))
	healthPerMatch = int(params.get("health_per_match", DEFAULT_HEALTH_PER_MATCH))
	trigger = String(effectData.trigger if effectData.trigger != "" else DEFAULT_TRIGGER)

func shouldQueueEffect() -> bool:
	return checkWoodsCardsOnBoard() > 0

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

func apply():
	if not is_instance_valid(hostCard):
		push_warning("SolitaryBeast.apply: host card freed")
		return
	
	var woodsCount = checkWoodsCardsOnBoard()
	var adjusted = calculateStatsChange(woodsCount)
	
	hostCard.cardAttack = adjusted["attack"]
	hostCard.cardHealth = adjusted["health"]
	
	hostCard.updateCardVisuals()
