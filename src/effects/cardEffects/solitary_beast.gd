class_name SolitaryBeast

var host_card: Node2D
var target_type: String
var attack_per_match: int
var health_per_match: int#
var trigger: String

func _init(card: Node2D, effectData: Dictionary):
	host_card = card
	var params = effectData.get("parameters", {})
	target_type = params.get("count_condition", {}).get("target", "Woods")
	attack_per_match = params.get("attack_per_match", 1)
	health_per_match = params.get("health_per_match", 1)
	trigger = effectData.get("trigger", "card_played")  # Add this


func checkWoodsCardsOnBoard() -> int:
	var count = 0
	var slots = GameController.boardController.getOccupiedSlots()
	
	for slot in slots:
		if slot.currentCard && slot.currentCard.cardName == target_type:
			count += 1
	
	return count

func apply():
	print("EFFECTS DEBUG: 9) StatAugmentEffect.apply() called for: ", host_card.cardName)
	var woods_count = checkWoodsCardsOnBoard()
	print("EFFECTS DEBUG: 10) Found ", woods_count, " Woods cards on board")
	
	var attack_bonus = attack_per_match * woods_count
	var health_bonus = health_per_match * woods_count
	
	print("EFFECTS DEBUG: 11) Before - Attack: ", host_card.cardAttack, " Health: ", host_card.cardHealth)
	host_card.cardAttack += attack_bonus
	host_card.cardHealth += health_bonus
	print("EFFECTS DEBUG: 12) After - Attack: ", host_card.cardAttack, " Health: ", host_card.cardHealth)
	
	host_card.updateCardVisuals()
