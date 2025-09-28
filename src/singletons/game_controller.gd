extends Node
class_name GameManager

var boardController: BoardController
var playerDeck: PlayerDeck
var journeyDeck: JourneyDeck
var hand: Hand
var characterCard: Node2D

var currentTurn = 0
var preTurnActions: Array
var postTurnActions: Array

var current_state: GameStates = GameStates.SETUP

enum GameStates {
	SETUP,
	PRE_TURN,
	PLAYER_TURN,
	POST_TURN,
	MOVING,
	COMBAT,
	GAME_OVER
}

func _ready():
	GlobalSignalBus.connect("cardClicked", Callable(self, "onCardClicked"))
	print("GameManager: Connected to cardClicked signal")
	await get_tree().process_frame

func changeGameState(newState: GameStates):
	match newState:
			GameStates.SETUP:
				#await what has to happen
				#change state to next
				return 0
			GameStates.PRE_TURN:
				#1. is there a pre turn list ?
				#2. check actions in list and how long they will take.
				#3. pause player interaction with board and exicute actions account for branching.
				#4. flush the list
				#5. next turn so swap state
				return 0
			GameStates.PLAYER_TURN:
				#let player make changes
				#check the results into the post turn actions if any effects are triggered.
				#change state to next
				return 0
			GameStates.POST_TURN:
				#1. is there a post turn list ?
				#2. check actions in list and how long they will take.
				#3. pause player interaction with board and exicute actions account for branching.
				#4. flush the list
				#5. next turn so swap state
				return 0
			GameStates.MOVING:
				#change state to next
				return 0
			GameStates.COMBAT: # dont htink this will be needed as combat results will be worked int othe post turn stuff i think
				#await what has to happen
				#change state to next
				return 0
			GameStates.GAME_OVER:
				#await what has to happen
				#change state to next
				return 0

func addItemToPreTurnPhase(action):
	#add an item to a list
	return 0

func addItemToPostTurnPhase(action):
	#add an item to a list
	return 0

func processTurnPhase(phase):
	#workout howmuch time to lock for, lock, resolve actions
	#how will this work with knowing when a stage is done and what stage to do next
	#maybe a helper that adds up the actions, decideds the paus time in seconds, resolves the actions, clears the array/adds to the next array ?
	return 0

func setupBoard():
	print("GameManager: Setting up board...")
	if !boardController || !journeyDeck:
		push_error("GameManager: Missing references to board or journey deck")
		return
	
	if(GameConstants.playerCharacter != null):
		characterCard = CreateCard.createCard(GameConstants.playerCharacter)
	else:
		characterCard = CreateCard.createCard("C_0000")
	
	if !characterCard:
		push_error("GameManager: Failed to create character card")
		return
	
	var centerSlot = boardController.getCenterSlot()
	if !centerSlot:
		push_error("GameManager: Could not find center slot")
		return
	
	boardController.add_child(characterCard)
	
	centerSlot.setCurrentCard(characterCard)
	characterCard.global_position = centerSlot.global_position
	characterCard.setCardState(characterCard.cardState.IN_SLOT)
	characterCard.flipCard()

	await get_tree().process_frame  # Wait for card placement
	journeyDeck.fillEmptySlots()
	
	print("GameManager: Board setup complete")

func onCardClicked(card):
	if card.currentState == card.cardState.IN_HAND || card.currentState == card.cardState.BEING_DRAGGED:
		return
	
	if card.get("isPlayerCard") == true:
		return
	
	var characterCard = findCharacterCardOnBoard()
	if !characterCard:
		return
	
	var characterCardSlot = characterCard.get_parent()
	var targetSlot = card.get_parent()
	
	if !characterCardSlot || !targetSlot:
		return
	
	if !isValidMove(characterCardSlot, targetSlot):
		return
	
	attemptToMove(characterCard, targetSlot)

func findCharacterCardOnBoard():
	var occupiedSlots = boardController.getOccupiedSlots()
	for slot in occupiedSlots:
		var card = slot.currentCard
		if card && card.get("isPlayerCard") == true:
			return card
	return null

func isValidMove(fromSlot, destinationSlot):
	var fromCoords = fromSlot.coordinates
	var destinationCoords = destinationSlot.coordinates
	
	var xDiff = abs(fromCoords.x - destinationCoords.x)
	var yDiff = abs(fromCoords.y - destinationCoords.y)
	
	return (xDiff == 1 && yDiff == 0) || (xDiff == 0 && yDiff == 1)

func attemptToMove(characterCard, targetSlot):
	var fromSlot = characterCard.get_parent()
	
	if targetSlot.cardInSlot:
		var targetCard = targetSlot.currentCard
		var battleResult = calculateBattle(characterCard, targetCard)
		if battleResult.success:
			moveCard(characterCard, targetSlot)
			await get_tree().process_frame
			journeyDeck.revealTopCard(fromSlot)
	else:
		moveCard(characterCard, targetSlot)
		await get_tree().process_frame
		journeyDeck.revealTopCard(fromSlot)

func calculateBattle(attacker, defender):
	print("Battle: ", attacker.cardName, " vs ", defender.cardName)
	
	var attackerWins = attacker.cardAttack > defender.cardHealth
	var attackerSurvives = attacker.cardHealth > defender.cardAttack
	
	if defender.cardType == "buff":
		attacker.cardHealth += defender.cardHealth
		attacker.cardAttack += defender.cardAttack
		attacker.updateCardVisuals()
		
		var result = {
			"success": true,
			"damage": 0,
			"attackerDied": false,
			"isBuff": true
			}
		defender.queue_free()
		
		GlobalSignalBus.emit_signal("battleCompleted", attacker, defender, result)
		return result
	
	attackerWins = attacker.cardAttack > defender.cardHealth
	attackerSurvives = attacker.cardHealth > defender.cardAttack
	
	if defender.cardAttack > 0:
		applyDamageToCard(attacker, defender.cardAttack)
	
	if attackerSurvives && !attackerWins:
		applyDamageToCard(defender, attacker.cardAttack)
		if defender.cardHealth == 0 ||  defender.cardHealth < 0:
			attackerWins = true
	
	var result = {
		"success": attackerWins && attackerSurvives,
		"damage": defender.cardAttack,
		"attackerDied": !attackerSurvives
	}
	
	if attackerWins:
		defender.queue_free()
	
	GlobalSignalBus.emit_signal("battleCompleted", attacker, defender, result)
	return result

func moveCard(card, targetSlot):
	var fromSlot = card.get_parent()
	
	if fromSlot && fromSlot.has_method("clearSlot"):
		fromSlot.clearSlot()
	
	targetSlot.setCurrentCard(card)
	GlobalSignalBus.emit_signal("cardMoved", card, fromSlot, targetSlot)

func applyDamageToCard(card, amount):
	var newHealth = card.cardHealth - amount
	card.cardHealth = newHealth
	card.updateCardVisuals()
	
	GlobalSignalBus.emit_signal("cardDamaged", card, amount, newHealth)
	
	if newHealth <= 0:
		pass
	
