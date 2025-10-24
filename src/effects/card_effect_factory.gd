class_name CardEffectFactory

static func createCardEffect(card: Node2D, effectData: EffectData):
	if effectData == null:
		push_error("CardEffectFactory.createCardEffect: effect_data is null")
		return null
	
	var effectType = effectData.effectType.strip_edges().to_lower()
	
	if effectType == "":
		push_error("CardEffectFactory.createCardEffect: missing effect type in the effect data")
		return null

	match effectType:
		"solitary_beast":
			var effectInstance := SolitaryBeast.new(card, effectData)
			if effectInstance == null || !effectInstance.has_method("apply"):
				push_error("CardEffectFactory: constructor for " + effectType + " returned invalid instance")
				return null
			return effectInstance
		# Add more effect types here (damage, draw, spawn, etc.)
		_:
			push_warning("CardEffectFactory: Unknown effect type " + effectType)
			return null
