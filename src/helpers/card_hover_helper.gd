class_name CardHoverHelper

func applyHoverEffect(card, isHovered):
	if card.currentState == card.cardState.BEING_DRAGGED:
		return
	if isHovered:
		card.scale = Vector2(1.05,1.05)
		CardZIndexManager.cardFocused(card, "true")
	else:
		card.scale = Vector2(1.0,1.0)
		CardZIndexManager.cardFocused(card, "false")
