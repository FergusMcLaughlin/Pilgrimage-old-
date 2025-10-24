class_name AddCardEffectToCardHelper

static func setupCardEffects(card, cardData):
	if cardData.effects.is_empty():
		print("No effects on card: ", cardData.name)
		return
	
	for effectData in cardData.effects:
		if effectData == null:
			push_warning("Card " + cardData.name + " has null effect reference")
			continue
		
		var cardEffect = CardEffectFactory.createCardEffect(card, effectData)
		if cardEffect== null:
			push_error("EffectFactory returned null for " + cardData.name + " (effect_type: " + effectData.effect_type + ")")
			continue
		
		EffectMediator.addListner(card, cardEffect)
