class_name AddCardEffectToCardHelper

static func setupCardEffects(card, cardData: CardData):
	var effectName = getEffectsOnCard(cardData)
	print("AddCardEffectToCardHelper: effectName for ", cardData.cardName, " = ", effectName)
	
	if(effectName == null || effectName == ""):
		return
	
	if(!EffectDictionaryJsonLoader.effectData.has(effectName)):
		push_error("Effect '%s' not found in effect dictionary" % effectName)
		return
		
	var effectData = EffectDictionaryJsonLoader.effectData[effectName]
	var cardEffect = CardEffectFactory.createCardEffect(card, effectData)
		
	if cardEffect == null:
		push_error("EffectFactory returned null for %s, it had an effect of type %s" % [cardData.cardName, effectData.effect_type])
		return
		
	print("EFFECT SYSTEM: 2) Created effect for ", card.cardName, " - Effect type: ", effectData.effect_type)
	EffectMediator.addListner(card, cardEffect)
	print("EFFECT SYSTEM: 3) Registered ", card.cardName, " as listener")

static func getEffectsOnCard(cardData: CardData):
	if(cardData.cardEffects.size() > 0):
		return cardData.cardEffects[0]
	return null
