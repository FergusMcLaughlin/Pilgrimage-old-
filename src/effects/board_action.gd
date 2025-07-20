class_name BoardAction

static func executeAction(actionData: Dictionary, queryResult = null, sourceCard = null):
	var actionType = actionData.get("action", "")
	
	match actionType:
		"modify_stats":
			return actionModifyStats(actionData, queryResult, sourceCard)
		#"destroy":
			#return actionDestroy(actionData, queryResult, sourceCard)
		#"spawn":
			#return actionSpawn(actionData, queryResult, sourceCard)
		#"move":
			#return actionMove(actionData, queryResult, sourceCard)
		"add_to_deck":
			return actionAddToDeck(actionData, queryResult, sourceCard)
		_:
			push_warning("BoardAction: Unknown action?")
			return false

#___________________________________________________________________________________________________
static func actionModifyStats(actionData: Dictionary, queryResult = null, sourceCard = null):
	var target = ResolveActionsHelper.resolveTarget(actionData.get("target", ""), queryResult, sourceCard)
	var stat = actionData.get("stat", "attack") 
	var amount = ResolveActionsHelper.calculateAmount(actionData, queryResult)
	
	if !target:
		return false
	
	var command = EffectCommand.statBoost(target, stat, amount)
	CommandProcessor.batch([command])
	
	print("BoardAction: Modified ", target.cardName, " ", stat, " by ", amount)
	return true

#static func actionDestroy(actionData: Dictionary, queryResult = null, sourceCard = null):
	#var targets = ResolveActionsHelper.resolveTargets(actionData.get("target", ""), queryResult, sourceCard)
	#
	#if !targets:
		#return false
	#
	#var commands = []
	#for card in targets:
		#var slot = card.get_parent()
		#if slot && slot.has_method("clearSlot"):
			#var destroyCommand = EffectCommand.destroyCard(card)
			#commands.append(destroyCommand)
	#
	#if !commands.is_empty():
		#CommandProcessor.batch(commands)
		#print("BoardAction: Destroying ", commands.size(), " cards")
		#return true
#
	#return false

#static func actionSpawn(actionData: Dictionary, queryResult = null, sourceCard = null):
	#var cardId = actionData.get("card", "")
	#var location = actionData.get("location", "random_empty")
	#
	#if cardId.is_empty():
		#return false
	#
	#var targetSlot = ResolveActionsHelper.resolveSpawnLocation(location)
	#
	#if !targetSlot:
		#print("BoardAction: No available slot for spawn")
		#return false
	#
	#var newCard = CreateCard.createCard(cardId)
	#
	#if !newCard:
		#return false
	#
	#var command = EffectCommand.spawnCard(newCard, targetSlot)
	#CommandProcessor.batch([command])
	#
	#print("BoardAction: Spawned ", cardId, " at slot ", location)
	#return true

#static func actionMove(actionData: Dictionary, queryResult = null, sourceCard = null):
	#var target = ResolveActionsHelper.resolveTarget(actionData.get("target", ""), queryResult, sourceCard)
	#var destination = actionData.get("destination", "")
	#
	#if !target:
		#return false
		#
	#var targetSlot = ResolveActionsHelper.resolveDestination(destination, target)
	#if !targetSlot:
		#return false
	#
	#var command = EffectCommand.moveCard(target, targetSlot)
	#CommandProcessor.batch([command])
	#
	#print("BoardAction: Moved ", target.cardName, " to new location")
	#return true
	

static func actionAddToDeck(actionData: Dictionary, queryResult = null, sourceCard = null):
	var cardId = actionData.get("card", "")
	var deckType = actionData.get("deck", "player")
	
	if cardId.is_empty():
		return false
