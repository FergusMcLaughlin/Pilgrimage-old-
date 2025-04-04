class_name CardHoverHelper

func applyHoverEffect(card, isHovered):
	if card.currentState == card.cardState.BEING_DRAGGED:
		return
	if isHovered:
		card.scale = Vector2(1.05,1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1.0,1.0)
		card.z_index = 1
