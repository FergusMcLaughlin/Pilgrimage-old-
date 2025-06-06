class_name CardEffectFactory

static func createEffect(card: Node2D, effectData: Dictionary) -> CardEffect:
	var effectType = effectData.get("type", "")
	
	match effectType:
		"stat_augmentation":
			return StatAugmentation.new(card, effectData)
		#add new effects in here
		_:
			push_warning("CardEffectFactory: no effectType found.")
			return null
		
