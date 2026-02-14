class_name  CardDataFactory

static func loadDictionary(dictionary: Dictionary) -> CardData:
	var data = CardData.new()
	data.cardId         = dictionary.get("id", "")
	data.cardName       = dictionary.get("name", "")
	data.cardType       = dictionary.get("type", "")
	data.cardBaseHealth     = dictionary.get("health", 0)
	data.cardBaseAttack     = dictionary.get("attack", 0)
	data.cardIsPlayer   = dictionary.get("isPlayer", false)
	data.cardIsUnlocked = dictionary.get("isUnlocked", false)
	data.cardImagePath  = dictionary.get("image_path", "")

	var effects: Array[String] = []
	
	# "effects": ["solitary_beast", "effect_woods"]
	if dictionary.has("effects"):
		var rawEffects = dictionary["effects"]
		if rawEffects is Array:
			for e in rawEffects:
				effects.append(str(e))
		elif rawEffects != null:
			effects.append(str(rawEffects))
			
	# "effect": "solitary_beast" or ["solitary_beast"] 
	elif dictionary.has("effect"):
		var singleEffect = dictionary["effect"]
		if singleEffect is Array:
			for e in singleEffect:
				effects.append(str(e))
		elif singleEffect != null:
			effects.append(str(singleEffect))
	
	data.cardEffects = effects


	return data
