extends Node2D

var cardId: String
var cardName: String
var cardType: String
var cardHealth: int
var cardAttack: int
var cardImagePath: String
var cardEffects: Array = [] 
var baseAttack: int                  
var baseHealth: int

const STAT_COLOR_NORMAL = Color.BLACK
const STAT_COLOR_BUFFED = Color.DARK_GREEN
const STAT_COLOR_DEBUFFED = Color.DARK_RED

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

func _ready():
	$Area2D.connect("mouse_entered", Callable(self, "onCardAreaEntered"))
	$Area2D.connect("mouse_exited", Callable(self, "onCardAreaExited"))
	$Area2D.connect("input_event", Callable(self, "onCardAreaInputEvent"))
	$Area2D.collision_layer = GameConstants.LAYER_CARD
	$Area2D.collision_mask = 0
	
	#cardeffectdebug
	CardEffectBus.subscribe("card_played_did", _on_other_card_played, 5 , self)
	
	shadowHelper = CardShadowHelper.new(self)

func initialiseCard (cardData):
	cardId = cardData["id"]
	cardName = cardData["name"]
	cardType = cardData["type"]
	cardHealth = cardData["health"]
	cardAttack = cardData["attack"]
	
	cardEffects = cardData.get("effects", [])
	baseAttack = cardAttack
	baseHealth = cardHealth
	
	cardImagePath = str("res://assets/images/cards/" + cardName +".png")
	
	updateCardVisuals()

func resetToBaseStats():
	cardAttack = baseAttack
	cardHealth = baseHealth

func updateCardVisuals ():
	$Name.text = cardName
	$Health.text = str(cardHealth)
	$Attack.text = str(cardAttack)
	
	updateStatColours()
	
	var texture = load(cardImagePath)
	if texture:
		$CardFace.texture = texture
		$CardFace.scale = Vector2(0.1, 0.1)
	else: 
		push_error("Cant load card picture: " + cardImagePath)

func updateStatColours():
	if cardType == "player":
		return
	
	if cardAttack > baseAttack:
		$Attack.modulate = STAT_COLOR_BUFFED 
	elif cardAttack < baseAttack:
		$Attack.modulate = STAT_COLOR_DEBUFFED 
	else:
		$Attack.modulate = STAT_COLOR_NORMAL
	
	if cardHealth > baseHealth:
		$Health.modulate = STAT_COLOR_BUFFED 
	elif cardHealth < baseHealth:
		$Health.modulate = STAT_COLOR_DEBUFFED
	else:
		$Health.modulate = STAT_COLOR_NORMAL

func setCardState (newCardState):
	var oldState = currentState
	currentState = newCardState
	print(get_parent())
	scale = Vector2(1.0, 1.0)
	
	if shadowHelper == null:
		shadowHelper = CardShadowHelper.new(self)
	
	match currentState:
		cardState.IN_DECK:
			print("card in deck")
			CardZIndexManager.setCardZIndex(self, "DEFUALT")
			$Area2D.input_pickable = false
			shadowHelper.setShadowVisible(false)
			
		cardState.IN_HAND:
			print("card in hand")
			if !isReturningToLocation:
				CardZIndexManager.setCardZIndex(self, "IN_HAND")
			$Area2D.input_pickable = true
			shadowHelper.setShadowVisible(true)
			
			
		cardState.ON_BOARD:
			print("card on board")
			if !isReturningToLocation:
				CardZIndexManager.setCardZIndex(self, "ON_BOARD")
			$Area2D.input_pickable = true
			shadowHelper.setShadowVisible(false)
			
		cardState.BEING_DRAGGED:
			print("card being dragged")
			if !isReturningToLocation:
				CardZIndexManager.setCardZIndex(self, "DRAGGING")
			scale = Vector2(1.05, 1.05)
			$Area2D.input_pickable = false
			if newCardState == cardState.BEING_DRAGGED:
				isReturningToLocation = false
			shadowHelper.setShadowVisible(true, true)
			
		cardState.IN_SLOT:
			print("card in slot")
			CardZIndexManager.setCardZIndex(self, "IN_SLOT")
			$Area2D.input_pickable = true
			shadowHelper.setShadowVisible(false)
		
			
	if scale != Vector2(1.0,1.0):
		shadowHelper.updateShadowForScale(scale)
	
	GlobalSignalBus.emit_signal("cardStateChanged", self, oldState, newCardState)

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
	GlobalSignalBus.emit_signal("cardFlipped", self)

func getEffectDescription() -> String:
	if cardEffects.is_empty():
		return ""
	
	var descriptions = []
	var effectManager = get_node("/root/EffectManager")
	
	for individualEffect in cardEffects:
		var effectData = effectManager.effectDefinitions.get(individualEffect, {})
		var description = effectData.get("description", "Unknown effect")
		descriptions.append(description)
	
	return "\n".join(descriptions)

func onReturnToHandComplete():
	print("Card return to hand complete!")
	isReturningToLocation = false
	
	if currentState == cardState.IN_HAND:
		CardZIndexManager.setCardZIndex(self, "IN_HAND")

func toggleShadow(isVisable):
	if shadowSprite != null:
		shadowSprite.visible = isVisable

func onCardAreaEntered():
	GlobalSignalBus.emit_signal("cardHovered", self)

func onCardAreaExited():
	GlobalSignalBus.emit_signal("cardUnhovered", self)

func onCardAreaInputEvent(_viewport,event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Card: Clicked detected, emitting cardClicked signal")
		if currentState == cardState.IN_SLOT:
			print("Card in slot clicked, emitting for movement only")
			GlobalSignalBus.emit_signal("cardClicked", self)
		elif currentState == cardState.IN_HAND:
			print("Card in hand clicked")
			GlobalSignalBus.emit_signal("cardClicked", self)
		else:
			GlobalSignalBus.emit_signal("cardClicked", self)

#cardeffectdebug
func _on_other_card_played(data: Dictionary):
	if data.card.cardType == "unit":
		print("s% gets +1/+1 from a special card on the feild ?", cardName)
