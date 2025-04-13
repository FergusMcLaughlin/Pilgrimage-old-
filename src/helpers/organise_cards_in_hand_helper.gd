class_name OrganiseCardsInHandHelper

var handWidth: float
var handHeight: float
var handCurve: Curve

func _init(width: float = 600.0, height: float = 100.0, curve: Curve = null):
	handWidth = width
	handHeight = height
	handCurve = curve

func getCardPosition(cardIndex: int, totalCards: int, centerOfHand: Vector2):
	var normalisedPosition = float(cardIndex) / max(1,totalCards - 1)
	
	var xOffset = lerp(-handWidth/2, handWidth/2, normalisedPosition)
	var yOffset = -handHeight * (handCurve.sample(normalisedPosition) if handCurve else 0.5)
	var position = centerOfHand + Vector2(xOffset, yOffset)
	var rotation = lerp(-PI/12, PI/12, normalisedPosition)
	
	return {
		"position": position,
		"rotation": rotation,
		"zIndex" : cardIndex
	}

func createCardTween(card, targetPosition: Vector2, targetRotation: float, duration = 0.3):
	var tween = card.create_tween() # kinda breaking encapsualtion ?
	tween.tween_property(card, "global_position", targetPosition, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(card, "rotation", targetRotation, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	return tween
