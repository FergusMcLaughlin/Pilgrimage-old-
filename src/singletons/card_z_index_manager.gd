extends Node

const LAYER_DEFAULT = 1
const LAYER_HOVERED = 2
const LAYER_HAND = 10
const LAYER_DRAGGING = 100
const LAYER_FOCUSED_IN_HAND = 15
const LAYER_BOARD_DEFUALT = 50
const LAYER_BOARD_TOP = 100

var cardStates = {}

func setCardZIndex(card, state):
	cardStates[card] = state
	
	match state:
		"DEFAULT":
			card.z_index = LAYER_DEFAULT
		"HOVERED":
			card.z_index = LAYER_HOVERED
		"HAND":
			card.z_index = LAYER_HAND
		"DRAGGING":
			card.z_index = LAYER_DRAGGING
		"FOCUSED_IN_HAND":
			card.z_index = LAYER_FOCUSED_IN_HAND
		"BOARD_DEFUALT":
			card.z_index = LAYER_BOARD_DEFUALT
		"BOARD_TOP":
			card.z_index = LAYER_BOARD_TOP
		_:
			card.z_index = LAYER_DEFAULT
	
	return card.z_index

func getCardState(card):
	return cardStates.get(card, "DEFAULT")

func setCardsInHandZIndex(card, indexInHand):
	var baseIndex = LAYER_HAND
	card.z_index = baseIndex + indexInHand
	return card.z_index

func cardFocused(card,focused):
	var currentState = getCardState(card)
	
	if currentState == "DRAGGING" || currentState == "IN_SLOT":
		return card.z_index
	
	if focused:
		card.z_index = LAYER_HOVERED
	else:
		card.z_index = setCardZIndex(card, currentState)
	
	return card.z_index
