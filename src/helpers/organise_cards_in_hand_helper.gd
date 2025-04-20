class_name OrganiseCardsInHandHelper

var handWidth: float
var handHeight: float
var handCurve: Curve
var cardWidth: float = 110.0
var cardSpacing: float = 15.0

func _init(width: float = 600.0, height: float = 100.0, curve: Curve = null):
	handWidth = width
	handHeight = height
	handCurve = curve

func getCardPosition(cardIndex: int, totalCards: int, centerOfHand: Vector2):
	var totalCardWidth = cardWidth * totalCards + cardSpacing * (totalCards - 1)
	var startX = centerOfHand.x - totalCardWidth / 2.0
	var xPosition = startX + cardIndex * (cardWidth + cardSpacing) + cardWidth / 2.0
	
	var curvePosition = (xPosition - (centerOfHand.x - handWidth / 2.0)) / handWidth
	curvePosition = clamp(curvePosition, 0.0, 1.0)
	
	var curveValue = 0.5
	if handCurve:
		curveValue = handCurve.sample(curvePosition)
	var yPosition = centerOfHand.y - handHeight * curveValue
	
	var distanceFromCenter = (xPosition - centerOfHand.x) / (handWidth / 2.0)
	var rotation = 0.0
	if totalCards > 1:
		rotation = distanceFromCenter * (PI/12.0)
	
	return {
		"position": Vector2(xPosition, yPosition),
		"rotation": rotation,
	}

func createCardTween(card, targetPosition: Vector2, targetRotation: float, duration = 0.3):
	var tween = card.create_tween() # kinda breaking encapsualtion ?
	tween.set_parallel(true)
	tween.tween_property(card, "global_position", targetPosition, duration).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "rotation", targetRotation, duration).set_ease(Tween.EASE_OUT)
	return tween
