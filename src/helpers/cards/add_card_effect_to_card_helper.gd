class_name AddCardEffectToCardHelper

static func setupCardEffects(card, cardData: CardData):
	var effectName = getEffectsOnCard(cardData)
	
	if(effectName == null || effectName == ""):
		return
		
	
	var effectData: EffectData = EffectDataRegistry.getEffectData(effectName)
	if effectData == null:
		return
	
	var cardEffect = CardEffectFactory.createCardEffect(card, effectData)
	if cardEffect == null:
		push_error("EffectFactory returned null for %s, it had an effect of type %s" % [cardData.cardName, effectData.effectType])
		return
		
	EffectMediator.addListner(card, cardEffect)

static func getEffectsOnCard(cardData: CardData):
	if(cardData.cardEffects.size() > 0):
		return cardData.cardEffects[0]
	return null
