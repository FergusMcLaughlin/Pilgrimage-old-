class_name CardEffectsHelper
extends Node

var hostCard: Node2D
var effectsDirector: EffectActionQueryDirector

func _init(card: Node2D):
	hostCard = card
	effectsDirector = EffectActionQueryDirector.new(card)

func initialise():
	subscribeToEvents()

func subscribeToEvents():
	GameEventsBrodcaster.subscribeToBrodcast(self, [
		GameEventsBrodcaster.EventType.SLOT_FILLED,
		GameEventsBrodcaster.EventType.SLOT_EMPTIED,
		GameEventsBrodcaster.EventType.CARD_PLAYED
	])
	print("CardEffectsHelper: Subscribed to events for card: ", hostCard.cardName)

func onEvent(event: EventBrodcast):
	print("🎯 CardEffectsHelper.onEvent called for ", hostCard.cardName, " with event: ", GameEventsBrodcaster.EventType.keys()[event.type])
	if !isValidEvent(event):
		print("   Event not valid, skipping")
		return
	
	match event.type:
		GameEventsBrodcaster.EventType.SLOT_FILLED:
			effectsDirector.onSlotFilled(event.target, event.source)
		GameEventsBrodcaster.EventType.SLOT_EMPTIED:
			effectsDirector.onSlotEmptied(event.target)
		GameEventsBrodcaster.EventType.CARD_PLAYED:
			effectsDirector.onCardPlayed(event.source, event.target)
		_:
			pass

func isValidEvent(event: EventBrodcast):
	if !hostCard || !hostCard.cardEffects || hostCard.cardEffects.is_empty():
		print("   Invalid event: no host card or effects")
		return false
	
	return true

func cleanup():
	GameEventsBrodcaster.unsubscribersToBrodcast(self)
	
	effectsDirector = null
	hostCard = null
	queue_free()
