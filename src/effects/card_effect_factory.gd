class_name CardEffectFactory

static var effectType: String

static func createCardEffect(card: Node2D, effectData: Dictionary):
	effectType = effectData.get("effect_type", "")

	match effectType:
		"solitary_beast":
			return SolitaryBeast.new(card, effectData)
		# Add more effect types here (damage, draw, spawn, etc.)
		_:
			push_warning("CardEffectFactory: Unknown effect type '%s'" % effectType)
			return null
