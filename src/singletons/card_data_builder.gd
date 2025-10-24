extends Node

var cards: Dictionary = {}
var effects: Dictionary ={}

func _ready():
	buildAllResourses()

func buildAllResourses():
	buildEffectResource()
	buildCardResource()

func buildEffectResource():
	for effectId in EffectDictionaryJsonLoader.effectData.keys():
		var raw = EffectDictionaryJsonLoader.effectData[effectId]
		var effectResourse = EffectData.new()
		effectResourse.name = raw.get("name", "")
		effectResourse.trigger = raw.get("trigger", "")
		effectResourse.timing = raw.get("timing", "")
		effectResourse.frequency = raw.get("frequency", "")
		effectResourse.effectType = raw.get("effect_type", "")
		effectResourse.parameters = raw.get("parameters", {})
		effects[effectId] = effectResourse
	print("Built ", effects.size(), " EffectData resources.")

func buildCardResource():
	for cardId in CardDictionaryJsonLoader.cardData.keys():
		var raw = CardDictionaryJsonLoader.cardData[cardId]
		var cardResourse = CardData.new()
		cardResourse.id = cardId
		cardResourse.name = raw.get("name", "")
		cardResourse.type = raw.get("type", "")
		cardResourse.baseAttack = raw.get("attack", 0)
		cardResourse.baseHealth = raw.get("health", 0)
		cardResourse.imagePath = raw.get("image_path", "")
		
		# Attach prebuilt EffectData resources (if they exist)
		cardResourse.effects.clear()
		if raw.has("effect"):
			for eff_id in raw["effect"]:
				if effects.has(eff_id):
					cardResourse.effects.append(effects[eff_id])
				else:
					push_warning("Missing effect: " + eff_id)
		
		cards[cardId] = cardResourse
	print("Built ", cards.size(), " CardData resources.")
