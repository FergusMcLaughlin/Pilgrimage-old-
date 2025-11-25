class_name  CardDataFactory

static func loadDictionary(dictionary: Dictionary) -> cardData:
	var data = cardData.new()
	data.cardId         = dictionary.get("id", "")
	data.cardName       = dictionary.get("name", "")
	data.cardType       = dictionary.get("type", "")
	data.cardHealth     = dictionary.get("health", 0)
	data.cardAttack     = dictionary.get("attack", 0)
	data.cardIsPlayer   = dictionary.get("isPlayer", false)
	data.cardIsUnlocked = dictionary.get("isUnlocked", false)
	data.cardImagePath  = dictionary.get("image_path", "")
	data.cardEffects    = dictionary.get("effects", [])
	return data
