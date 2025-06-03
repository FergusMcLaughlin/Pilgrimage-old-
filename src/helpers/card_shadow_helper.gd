class_name CardShadowHelper

const SHADOW_OPACITY = 0.3
const SHADOW_OFFSET_DEFAULT = Vector2(5,5)

var cardNode: Node2D
var shadowSprite: Sprite2D

func _init(card: Node2D):
	cardNode = card
	createShadow()

func createShadow():
	if shadowSprite != null && is_instance_valid(shadowSprite):
		shadowSprite.queue_free()
	
	if !cardNode.has_node("CardBack"):
		push_error("No card back sprite for the shadow to use")
		return
	
	shadowSprite = Sprite2D.new()
	shadowSprite.texture = cardNode.get_node("CardBack").texture
	shadowSprite.modulate = Color(0,0,0,0.3)
	shadowSprite.scale = cardNode.get_node("CardBack").scale * 1.05
	shadowSprite.position = SHADOW_OFFSET_DEFAULT
	
	shadowSprite.z_index = -1
	shadowSprite.visible = false
	
	cardNode.add_child(shadowSprite)

func setShadowVisible(isVisible: bool, isDragging: bool = false, isFocused: bool = false):
	if shadowSprite == null || !is_instance_valid(shadowSprite):
		createShadow()
	
	shadowSprite.visible = isVisible
	
	if isVisible:
		if isDragging || isFocused || (isDragging && isFocused):
			shadowSprite.position = SHADOW_OFFSET_DEFAULT * 1.6
			shadowSprite.modulate.a = 0.4
			shadowSprite.scale = cardNode.get_node("CardBack").scale * 0.95
		else:
			shadowSprite.position = SHADOW_OFFSET_DEFAULT
			shadowSprite.modulate.a = SHADOW_OPACITY
			shadowSprite.scale = cardNode.get_node("CardBack").scale * 1.05

func updateShadowForScale(cardScale: Vector2):
	if shadowSprite == null || !is_instance_valid(shadowSprite) || !shadowSprite.visible:
		return
	
	var inverseScale = 1.0 / cardScale.x
	var shadowBasicScale = cardNode.get_node("CardBack").scale
	
	shadowSprite.scale = shadowBasicScale * (1.05 * inverseScale)
	
	var offsetMultiplier = max(1.0, cardScale.x * 1.5)
	shadowSprite.position = SHADOW_OFFSET_DEFAULT * offsetMultiplier
