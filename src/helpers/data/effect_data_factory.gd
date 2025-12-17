class_name EffectDataFactory

static func loadDictionary(effectId: String, dictionary: Dictionary) -> EffectData:
	var data := EffectData.new()

	data.effectId = dictionary.get("id", effectId)
	data.effectName = dictionary.get("name", data.effectId)
	data.effectTrigger = dictionary.get("trigger", "card_played")
	data.effectTiming = dictionary.get("timing", "immediate")
	data.effectFrequency = dictionary.get("frequency", "repeatable")
	data.effectType = dictionary.get("effect_type", data.effectId)
	data.effectParameters = dictionary.get("parameters", {})
	
	return data
