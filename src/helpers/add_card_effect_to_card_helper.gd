class_name AddCardEffectToCardHelper

static func setupCardEffects(card, cardData):
	var effectName = getEffectsOnCard(cardData)
	
	if effectName != null and effectName != "":
		if not EffectDictionaryJsonLoader.effectData.has(effectName):
			push_error("Effect '%s' not found in effect dictionary" % effectName)
			return
		
		var effectData = EffectDictionaryJsonLoader.effectData[effectName]
		var cardEffect = CardEffectFactory.createCardEffect(card, effectData)
		print("EFFECT SYSTEM: 2) Created effect for ", card.cardName, " - Effect type: ", effectData.effect_type)
		EffectMediator.addListner(card, cardEffect)
		print("EFFECT SYSTEM: 3) Registered ", card.cardName, " as listener")

static func getEffectsOnCard(cardData):
	if cardData.has("effect") and cardData["effect"] != null:
		var effects = cardData["effect"]  # This is the array
		if effects.size() > 0:
			return effects[0]  # Get first effect as string
	return null
