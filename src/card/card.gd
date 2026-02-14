extends Node2D

var cardData: CardData
var cardHealth: int
var cardAttack: int
var cardImagePath: String
var effectName: String

enum cardState {
	ON_BOARD,
	IN_DECK,
	IN_HAND,
	BEING_DRAGGED,
	IN_SLOT
}

var currentState: int = cardState.IN_DECK 
var shadowSprite: Sprite2D
var isReturningToLocation: bool = false
var shadowHelper: CardShadowHelper
var movementTween: Tween = null

func _ready():
	$Area2D.connect("mouse_entered", Callable(self, "onCardAreaEntered"))
	$Area2D.connect("mouse_exited", Callable(self, "onCardAreaExited"))
	$Area2D.connect("input_event", Callable(self, "onCardAreaInputEvent"))
	$Area2D.collision_layer = GameConstants.LAYER_CARD
	$Area2D.collision_mask = 0
	
	shadowHelper = CardShadowHelper.new(self)

func initialiseCard (data: CardData):
	cardData = data
	
	cardHealth = data.cardBaseHealth
	cardAttack = data.cardBaseAttack
	
	cardImagePath = str("res://assets/images/cards/" + cardData.cardName +".png") #this is not data driven at the min
	
	AddCardEffectToCardHelper.setupCardEffects(self, cardData)
	
	updateCardVisuals()
	
func updateCardVisuals ():
	$Name.text = cardData.cardName
	$Health.text = str(cardHealth)
	$Attack.text = str(cardAttack)
	
	CardStatColourHelper.updateStatColours(cardData.cardType, cardAttack, cardData.cardBaseAttack, cardHealth, cardData.cardBaseHealth, $Attack, $Health)
	
	var texture = load(cardImagePath)
	if texture:
		$CardFace.texture = texture
		$CardFace.scale = Vector2(0.1, 0.1)
	else: 
		push_error("Cant load card picture: " + cardImagePath)

func setCardState (newCardState):
	var oldState = currentState
	currentState = newCardState
	scale = Vector2(1.0, 1.0)
	
	if shadowHelper == null:
		shadowHelper = CardShadowHelper.new(self)
	
	match currentState:
		cardState.IN_DECK:
			CardZIndexManager.setCardZIndex(self, "DEFUALT")
			$Area2D.input_pickable = false
			shadowHelper.setShadowVisible(false)
			
		cardState.IN_HAND:
			if !isReturningToLocation:
				CardZIndexManager.setCardZIndex(self, "IN_HAND")
			$Area2D.input_pickable = true
			shadowHelper.setShadowVisible(true)
			
			
		cardState.ON_BOARD:
			if !isReturningToLocation:
				CardZIndexManager.setCardZIndex(self, "ON_BOARD")
			$Area2D.input_pickable = true
			shadowHelper.setShadowVisible(false)
			
		cardState.BEING_DRAGGED:
			if !isReturningToLocation:
				CardZIndexManager.setCardZIndex(self, "DRAGGING")
			scale = Vector2(1.05, 1.05)
			$Area2D.input_pickable = false
			if newCardState == cardState.BEING_DRAGGED:
				isReturningToLocation = false
			shadowHelper.setShadowVisible(true, true)
			
		cardState.IN_SLOT:
			CardZIndexManager.setCardZIndex(self, "IN_SLOT")
			$Area2D.input_pickable = true
			shadowHelper.setShadowVisible(false)
		
			
	if scale != Vector2(1.0,1.0):
		shadowHelper.updateShadowForScale(scale)
	
	GlobalSignalBus.emitCardStateChanged(self, oldState, newCardState)

func _set(property, value):
	if property == "scale" && shadowHelper != null:
		shadowHelper.updateShadowForScale(value)
	return false

func flipCard ():
	var tween = create_tween()
	var shadowWasVisible = false
	if shadowHelper != null && shadowHelper.shadowSprite != null:
		shadowWasVisible = shadowHelper.shadowSprite.visible
		shadowHelper.setShadowVisible(false)
	else:
		shadowHelper = CardShadowHelper.new(self)
	
	tween.tween_property(self, "scale:x", 0, 0.15)
	tween.tween_callback(func():
		# Toggle visibility of front and back
		$CardFace.visible = !$CardFace.visible
		$CardBack.visible = !$CardBack.visible
		
		$Name.visible = !$Name.visible
		$Health.visible = 	!$Health.visible
		$Attack.visible = 	!$Attack.visible
		
		)
	tween.tween_property(self, "scale:x", 1, 0.15)
	tween.tween_callback(func():
		if shadowHelper != null && shadowWasVisible && currentState in [cardState.IN_HAND, cardState.BEING_DRAGGED]:
			var isDragging = currentState == cardState.BEING_DRAGGED
			shadowHelper.setShadowVisible(true, isDragging)
	)
	GlobalSignalBus.emitCardFlipped(self)

func moveToPosition(targetPosition: Vector2) -> void:
	if movementTween != null && movementTween.is_valid():
		movementTween.kill()
	
	movementTween = create_tween()
	movementTween.tween_property(self, "global_position", targetPosition, 0.3)
	movementTween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)

func onReturnToHandComplete():
	isReturningToLocation = false
	
	if currentState == cardState.IN_HAND:
		CardZIndexManager.setCardZIndex(self, "IN_HAND")

func toggleShadow(isVisable):
	if shadowSprite != null:
		shadowSprite.visible = isVisable

func onCardAreaEntered():
	GlobalSignalBus.emitCardHovered(self)

func onCardAreaExited():
	GlobalSignalBus.emitCardUnhovered(self)

func onCardAreaInputEvent(_viewport,event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if currentState == cardState.IN_SLOT:
			GlobalSignalBus.emitCardClicked(self)
		elif currentState == cardState.IN_HAND:
			GlobalSignalBus.emitCardClicked(self)
		else:
			GlobalSignalBus.emitCardClicked(self)

func cleanUpEffects() -> void:
	EffectMediator.removeListnersForCard(self)
