extends Node

var characterCardNameList = []
var getCardsOfTypeFromDictionaryHelper: GetCardsOfTypeFromDictionaryHelper
var characterCards = []
@onready var boardNode = $Panel/CardGrid

var focusedCharacter
var selectedCharacter

func _ready():
	$BackButton.connect("pressed", Callable(self, "on_back_button_pressed"))
	$QuitButton.connect("pressed", Callable(self, "on_quit_button_pressed"))
	GlobalSignalBus.connect("cardClicked", selectCharacter)
	
	createCharacterCards()
	await get_tree().process_frame
	placeCharacterCardsInGrid()
	if has_node("Panel"):
		var panel = get_node("Panel")
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("Set panel mouse filter to IGNORE")
	testSignalConnection()

func testSignalConnection():
	print("Testing signal connection...")
	if GlobalSignalBus.is_connected("cardClicked", focusCharacter):
		print("✓ Signal is connected properly")
	else:
		print("✗ Signal is NOT connected")

func createCharacterCards():
	getCardsOfTypeFromDictionaryHelper = GetCardsOfTypeFromDictionaryHelper.new()
	characterCardNameList.append_array(getCardsOfTypeFromDictionaryHelper.getCardsOfType("player"))
	
	for cardId in characterCardNameList:
		var cardInstance = CreateCard.createCard(cardId)
		if cardInstance:
			cardInstance.flipCard()
			cardInstance.setCardState(cardInstance.cardState.ON_BOARD)
			characterCards.append(cardInstance)

func placeCharacterCardsInGrid():
	if !boardNode || !boardNode.has_method("getEmptySlots"):
		push_error("JourneyDeck: Board not found or the getEmptySlots function's not there ?")
		return
	var emptySlots = boardNode.getEmptySlots()
	var delayBetweenCards = 0.04
	
	for i in range(min(characterCards.size(), emptySlots.size())):
		var card = characterCards[i]
		var slot = emptySlots[i]
		
		placeCardInSlot(card, slot)
		await get_tree().create_timer(delayBetweenCards).timeout

func placeCardInSlot(card, slot):
	boardNode.add_child(card)
	card.global_position = slot.global_position
	slot.setCurrentCard(card)
	CardZIndexManager.setCardZIndex(card, "ON_BOARD")


func focusCharacter(card):
	if card in characterCards:
		if focusedCharacter != null:
			focusedCharacter.scale = Vector2(1.0, 1.0)
		focusedCharacter = card
		focusedCharacter.scale = Vector2(1.1, 1.1)
		print("Focused character: " + focusedCharacter.cardName)
	else:
		print("Clicked card is not a character card")


func selectCharacter(card):
	if card in characterCards:
		if selectedCharacter != null:
			selectedCharacter.scale = Vector2(1.0, 1.0)
		selectedCharacter = card
		selectedCharacter.scale = Vector2(1.1, 1.1)
		GameConstants.playerCharacter = selectedCharacter.cardId
		print(selectedCharacter.cardId)
	else:
		print("Clicked card is not a character card")

func on_back_button_pressed():
	SceneTransitionManager.transitionToScene("res://src/ui/mainMenu/main_menu.tscn", SceneTransitionManager.TransitionType.FADE)

func on_quit_button_pressed():
	get_tree().quit()
