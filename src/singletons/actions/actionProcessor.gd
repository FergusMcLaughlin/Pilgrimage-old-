extends Node

var _isBusy: bool = false
#NEED TO LOOK AT HERE
func _process(_delta: float) -> void:
	if _isBusy:
		return
	if !ActionQueue.queueHasActions():
		return

	var action: Dictionary = ActionQueue.popNextAction()
	if action.is_empty():
		return

	_isBusy = true
	_runAction(action)
	_isBusy = false

func _runAction(action: Dictionary) -> void:
	print("PROCESSOR runAction:", action)
	if is_instance_valid(EffectMediator) and EffectMediator.has_method("onActionPre"):
		EffectMediator.onActionPre(action)

	_resolveAction(action)

	if is_instance_valid(EffectMediator) and EffectMediator.has_method("onActionPost"):
		EffectMediator.onActionPost(action)

func _resolveAction(action: Dictionary) -> void:
	var actionType := str(action.get("type", ""))

	match actionType:
		ActionTypes.PLAY_CARD:
			_handle_play_card(action)
		ActionTypes.REVEAL_CARD:
			_handle_reveal_card(action)
		ActionTypes.MODIFY_STATS:
			_handleModifyStats(action)
		ActionTypes.DESTROY_CARD:
			_handleDestroyCard(action)
		_:
			push_warning("[ActionProcessor] Unknown action type: %s | %s" % [actionType, action])


func _handle_play_card(action: Dictionary) -> void:
	var card = action.get("source", null)
	var slot = action.get("target", null)

	if card == null or !is_instance_valid(card):
		push_warning("PLAY_CARD: missing/invalid source")
		return
	if slot == null or !is_instance_valid(slot):
		push_warning("PLAY_CARD: missing/invalid target")
		return

	# Optional: final validation guard
	if slot.has_method("canAcceptCard") and !slot.canAcceptCard(card):
		GlobalSignalBus.emitCardPlacementInvalid(card,slot)
		return

	# TODO: move your old direct play placement here:
	card.setCardState(card.cardState.ON_BOARD)

	var tween = create_tween()
	tween.tween_property(card, "global_position", slot.global_position, 0.3)
	tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.2)
	
	if slot.has_method("setCurrentCard"):
		slot.setCurrentCard(card)
	
	GlobalSignalBus.emitCardPlayed(card, slot)


func _handle_reveal_card(action: Dictionary) -> void:
	var deck = action.get("source", null) # JourneyDeck
	var slot = action.get("target", null)
	var card = action.get("data", {}).get("card", null)

	if card == null or !is_instance_valid(card):
		push_warning("REVEAL_CARD: invalid card")
		return
	if slot == null or !is_instance_valid(slot):
		push_warning("REVEAL_CARD: invalid slot")
		return

	card.setCardState(card.cardState.IN_SLOT)

	if card.has_node("CardBack") and card.has_node("CardFace"):
		if card.get_node("CardBack").visible and !card.get_node("CardFace").visible:
			card.flipCard()

	# Make it originate from the deck position (same as your old code)
	if deck != null and is_instance_valid(deck):
		deck.add_child(card)
		card.global_position = deck.global_position

	var tween = create_tween()
	tween.tween_property(card, "global_position", slot.global_position, 0.3)
	tween.parallel().tween_property(card, "rotation", slot.rotation, 0.3)
	tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.2)

	if slot.has_method("setCurrentCard"):
		slot.setCurrentCard(card)

	# Preserve previous signals/behavior
	if deck != null and is_instance_valid(deck) and deck.has_signal("journeyCardRevealed"):
		deck.emit_signal("journeyCardRevealed", card, slot)
	
	GlobalSignalBus.emitSlotFilled(slot,card)


func _handleModifyStats(action: Dictionary) -> void:
	var target = action.get("target", null)
	var data: Dictionary = action.get("data", {})
	
	if target == null or !is_instance_valid(target):
		push_warning("MODIFY_STATS: missing or incalid target")
		return
	
	var hasAttack := data.has("attack")
	var hasHealth := data.has("health")
	
	if !hasAttack && !hasHealth:
		push_warning("MODIFY_STATS: missing data.attack/health")
		return
	
	var changed = false
	
	if hasAttack:
		var new_attack := int(data["attack"])
		if target.cardAttack != new_attack:
			target.cardAttack = new_attack
			changed = true
	
	if hasHealth:
		var new_health := int(data["health"])
		if target.cardHealth != new_health:
			target.cardHealth = new_health
			changed = true
	
	if changed and target.has_method("updateCardVisuals"):
		target.updateCardVisuals()

func _handleDestroyCard(action: Dictionary) -> void:
	var destroyer = action.get("source", null)
	var destroyed = action.get("target", null)

	print("DESTROY:", "source=", destroyer, " target=", destroyed)

	if destroyed == null or !is_instance_valid(destroyed):
		push_warning("DESTROY_CARD: invalid destroyed")
		return

	# Example: remove from slot if it has a parent slot reference, then free
	if destroyed.get_parent() != null:
		destroyed.queue_free()
