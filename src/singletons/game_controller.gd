extends Node
class_name GameManager

var boardController: BoardController
var playerDeck: PlayerDeck
var journeyDeck: JourneyDeck
var hand: Hand
var characterCard: Node2D

var currentGameState = GameStates.SETUP

enum GameStates {
	SETUP,
	PLAYER_TURN,
	MOVING,
	COMBAT,
	GAME_OVER
}

func _ready():
	await get_tree().process_frame

func setupBoard():
	print("GameManager: Setting up board...")
	if !boardController || !journeyDeck:
		push_error("GameManager: Missing references to board or journey deck")
		return
	
	var characterCard = CreateCard.createCard("0000")
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
	characterCard.setCardState(characterCard.cardState.ON_BOARD)
	characterCard.flipCard()

	await get_tree().process_frame  # Wait for card placement
	journeyDeck.fillEmptySlots()
	
	print("GameManager: Board setup complete")
