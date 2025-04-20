extends Node2D
class_name Hand

@export var handWidth: float = 600.0
@export var handHeight: float = 100.0 
@export var cardSpacing: float = 14.85 #is this working ?
@export var orgonisationDuration: float = 0.3
@export var handCurve: Curve

var cardsInHand = []
var isOrganising = false
var organiseCardsInHandHelper: OrganiseCardsInHandHelper

func _ready():
	organiseCardsInHandHelper = OrganiseCardsInHandHelper.new()
	organiseCardsInHandHelper.handWidth = handWidth
	organiseCardsInHandHelper.handHeight = handHeight
	organiseCardsInHandHelper.handCurve = handCurve
	
	GlobalSignalBus.connect("cardDrawn", onCardDrawn)
	GlobalSignalBus.connect("cardReturnedToHand", onCardReturnedToHand)
	GlobalSignalBus.connect("cardDragStarted", onCardDragStarted)
	GlobalSignalBus.connect("slotFilled", onCardAddedToSlot)

func addCardToHand(card):
	if !cardsInHand.has(card):
		cardsInHand.append(card)
		add_child(card)
		card.setCardState(card.cardState.IN_HAND)
		
		if card.has_method("flipCard"):
			card.flipCard()
		
		card.global_position = global_position
		
		orgoniseCardsInHand()
		await get_tree().process_frame
		orgoniseCardsInHand()
		return true
	return false

func removeCardFromHand(card):
	if cardsInHand.has(card):
		cardsInHand.erase(card)
		remove_child(card)
	
		if !cardsInHand.is_empty():
			orgoniseCardsInHand()
		return true
	return false

func orgoniseCardsInHand():
	if isOrganising && cardsInHand.size() > 0:
		isOrganising = false
		return
	
	if cardsInHand.is_empty():
		return
	
	isOrganising = true
	var cardCount = cardsInHand.size()
	
	for i in range(cardCount):
		var card = cardsInHand[i]
		if card.currentState == card.cardState.BEING_DRAGGED:
			continue
		
		var  cardData = organiseCardsInHandHelper.getCardPosition(i, cardCount, global_position)
		
		if !card.isReturningToLocation:
			CardZIndexManager.setCardsInHandZIndex(card, i)
		else:
			CardZIndexManager.setReturningCardZIndex(card)
		
		var tween = organiseCardsInHandHelper.createCardTween(card, cardData.position, cardData.rotation, orgonisationDuration)
		
		if card.isReturningToLocation:
			var cardIndex = i
			tween.finished.connect(
				func():
					card.onReturnToHandComplete()
					CardZIndexManager.setCardsInHandZIndex(card, cardIndex)
			)
			
		if i == cardCount - 1:
			tween.finished.connect(
				func():
					isOrganising = false
			)
			
	await get_tree().create_timer(orgonisationDuration + 0.1).timeout
	isOrganising = false

func getCardCount():
	return cardsInHand.size()

func getCards():
	return cardsInHand

func clearHand():
	for card in cardsInHand.duplicate():
		removeCardFromHand(card)

func onCardDrawn(card):
	addCardToHand(card)

func onCardReturnedToHand(card):
	if cardsInHand.has(card):
		orgoniseCardsInHand()
	else:
		if card.get_parent() != self:
			if card.get_parent():
				card.get_parent().remove_child(card)
			add_child(card)
			
		card.setCardState(card.cardState.IN_HAND)
		
		var currentPosition = card.global_position
		card.global_position = currentPosition
		
		cardsInHand.append(card)
		
		await  get_tree().process_frame
		orgoniseCardsInHand()

func onCardDragStarted(card):
	if cardsInHand.has(card):
		card.z_index = 100

func onCardAddedToSlot(slot, card):
	if cardsInHand.has(card):
		removeCardFromHand(card)
