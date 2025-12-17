class_name CardEffectFactory

static func createCardEffect(card: Node2D, effectData: EffectData):
	var effectType := effectData.effectType.strip_edges().to_lower()
	if effectType == "":
		push_error("CardEffectFactory: missing effect type in EffectData")
		return null

	match effectType:
		"solitary_beast":
			var effectInstance = SolitaryBeast.new(card, effectData)
			if effectInstance == null or not effectInstance.has_method("apply"):
				push_error("CardEffectFactory: constructor for %s returned invalid instance" % effectType)
				return null
			return effectInstance
		# Add more effect types here
		_:
			push_warning("CardEffectFactory: Unknown effect type %s" % effectType)
			return null
