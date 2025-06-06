extends Node2D
var current_test_card = null
@onready var playerDeck = $GameBoard/playerDeck
@onready var journeyDeck = $GameBoard/journeyDeck
@onready var cardGrid = $GameBoard/CardGrid


func _ready():
	# Create a test card
	spawn_test_card()
	playerDeck.initialiseFromPreset("test")
	journeyDeck.initialiseJourneyDeck()
	
	# CRITICAL: Set currentBoard reference FIRST, before any other setup
	print("DEBUG: Setting currentBoard to GameBoard...")
	GlobalSignalBus.currentBoard = $GameBoard
	print("DEBUG: currentBoard set to: ", GlobalSignalBus.currentBoard)
	
	# Verify the board has the necessary methods
	if $GameBoard.has_method("getOccupiedSlots"):
		print("DEBUG: ✓ GameBoard has getOccupiedSlots method")
	else:
		push_error("DEBUG: ✗ GameBoard missing getOccupiedSlots method!")
	
	# Debug information about the scene
	print("\n----- SCENE DEBUG INFO -----")
	print_scene_tree()
	
	# Check if CardSlot exists
	if has_node("CardSlot"):
		print("\nCardSlot found at path: ", $CardSlot.get_path())
		print("CardSlot methods available:")
		print("- setCurrentCard: ", $CardSlot.has_method("setCurrentCard"))
		print("- clearSlot: ", $CardSlot.has_method("clearSlot"))
		print("- getGlobalSlotCenter: ", $CardSlot.has_method("getGlobalSlotCenter"))
	else:
		print("\nWARNING: No node named 'CardSlot' found!")
		
	# Connect UI buttons with the correct function names
	$Ui/ButtonPanel/findmiddleslotButton.pressed.connect(on_flip_button_pressed)
	$Ui/ButtonPanel/StateButton.pressed.connect(on_change_state_button_pressed)
	$Ui/ButtonPanel/DragButton.pressed.connect(on_test_drag_button_pressed)
	$Ui/ButtonPanel/MoveToSlotButton.pressed.connect(on_move_to_slot_button_pressed)
	$Ui/ButtonPanel/RemoveFromSlotButton.pressed.connect(on_remove_from_slot_button_pressed)
	$Ui/ButtonPanel/debug_button.pressed.connect(on_debug_button_pressed)
	
	# Connect new buttons for journey deck testing
	$Ui/ButtonPanel/fill_board.pressed.connect(on_fill_board_button_pressed)
	$Ui/ButtonPanel/fill_one_slot.pressed.connect(on_fill_one_slot_button_pressed)
	
	# Verify button connections
	print("\nButton connections:")
	print("- FlipButton connected: ", $Ui/ButtonPanel/findmiddleslotButton.is_connected("pressed", Callable(self, "on_flip_button_pressed")))
	print("- StateButton connected: ", $Ui/ButtonPanel/StateButton.is_connected("pressed", Callable(self, "on_change_state_button_pressed")))
	print("- DragButton connected: ", $Ui/ButtonPanel/DragButton.is_connected("pressed", Callable(self, "on_test_drag_button_pressed")))
	print("- MoveToSlotButton connected: ", $Ui/ButtonPanel/MoveToSlotButton.is_connected("pressed", Callable(self, "on_move_to_slot_button_pressed")))
	print("- RemoveFromSlotButton connected: ", $Ui/ButtonPanel/RemoveFromSlotButton.is_connected("pressed", Callable(self, "on_remove_from_slot_button_pressed")))
	print("- debug_button connected: ", $Ui/ButtonPanel/debug_button.is_connected("pressed", Callable(self, "on_debug_button_pressed")))
	print("- fill_board connected: ", $Ui/ButtonPanel/fill_board.is_connected("pressed", Callable(self, "on_fill_board_button_pressed")))
	print("- fill_one_slot connected: ", $Ui/ButtonPanel/fill_one_slot.is_connected("pressed", Callable(self, "on_fill_one_slot_button_pressed")))
	
	# IMPORTANT: Set up GameController AFTER currentBoard is set
	GameController.boardController = $GameBoard
	GameController.playerDeck = $GameBoard/playerDeck
	GameController.journeyDeck = $GameBoard/journeyDeck
	GameController.hand = $GameBoard/Hand
	
	# Verify currentBoard is still set after GameController setup
	print("DEBUG: currentBoard after GameController setup: ", GlobalSignalBus.currentBoard)
	
	GameController.setupBoard()
	
	# Final verification
	print("DEBUG: currentBoard after all setup: ", GlobalSignalBus.currentBoard)
	
	# Force a debug to see if BoardQueryHelper works now
	print("\n----- TESTING BOARD QUERY IMMEDIATELY -----")
	await get_tree().process_frame
	var testCount = BoardQueryHelper.countCardsOfType("location", "Woods")
	print("DEBUG: Immediate test - Woods count: ", testCount)

# New function for fill_board button using journeyDeck methods
func on_fill_board_button_pressed():
	print("\n----- FILL BOARD BUTTON PRESSED -----")
	
	if journeyDeck:
		print("Filling board with journey cards")
		# Use the journeyDeck's fillEmptySlots method
		journeyDeck.fillEmptySlots()
	else:
		print("ERROR: JourneyDeck not found or initialized")

# New function for fill_one_slot button using journeyDeck methods
func on_fill_one_slot_button_pressed():
	print("\n----- FILL ONE SLOT BUTTON PRESSED -----")
	
	if journeyDeck:
		print("Filling one empty slot with journey card")
		
		# Find an empty slot
		var emptySlot = find_first_empty_slot()
		
		if emptySlot:
			print("Found empty slot at position: " + str(emptySlot.global_position))
			# Use the journeyDeck's revealTopCard method
			var card = journeyDeck.revealTopCard(emptySlot)
			if card:
				print("Placed card " + card.cardName + " in slot")
			else:
				print("No more cards in journey deck")
		else:
			print("No empty slots found on board")
	else:
		print("ERROR: JourneyDeck not found or initialized")

# Helper function to find the first empty slot
func find_first_empty_slot():
	# Try with grid
	if cardGrid and cardGrid.has_method("getEmptySlots"):
		var emptySlots = cardGrid.getEmptySlots()
		if not emptySlots.is_empty():
			return emptySlots[0]
	
	# Direct approach - check all slots
	var slots = get_tree().get_nodes_in_group("cardSlot")
	for slot in slots:
		if not slot.cardInSlot:
			return slot
	
	return null

# Helper function to print the scene tree for debugging
func print_scene_tree(node = null, indent = ""):
	if node == null:
		node = self
		print("Scene tree structure:")
	
	print(indent + node.name + " (" + node.get_class() + ")")
	
	for child in node.get_children():
		print_scene_tree(child, indent + "  ")

# Existing functions...
func spawn_test_card():
	# Your existing implementation
	pass

func on_flip_button_pressed():
	print("\n----- TESTING GET CENTER SLOT -----")
	
	# Access the board controller
	if $GameBoard.has_method("getCenterSlot"):
		var centerSlot = $GameBoard.getCenterSlot()
		
		if centerSlot:
			print("Successfully found center slot!")
			print("Slot name: " + centerSlot.name)
			print("Slot position: " + str(centerSlot.global_position))
			print("Slot coordinates: " + str(centerSlot.coordinates))
			
			# For visual feedback, let's place a card in the center
			if playerDeck.has_method("drawCard"):
				var card = playerDeck.drawCard()
				if card:
					centerSlot.setCurrentCard(card)
					card.global_position = centerSlot.global_position
					print("Placed card in center slot for visualization")
		else:
			print("ERROR: Center slot not found")
	else:
		print("ERROR: GameBoard doesn't have getCenterSlot method")

func on_change_state_button_pressed():
	# Your existing implementation
	pass

func on_test_drag_button_pressed():
	# Your existing implementation
	pass

func on_move_to_slot_button_pressed():
	# Your existing implementation
	pass

func on_remove_from_slot_button_pressed():
	# Your existing implementation
	pass

func move_card_to_slot(slot):
	# Your existing implementation
	pass

func remove_card_from_slot(slot):
	# Your existing implementation
	pass

func on_debug_button_pressed():
	# Your existing implementation
	pass

func print_card_debug_info(card):
	# Your existing implementation
	pass

func find_all_cards_in_scene():
	# Your existing implementation
	pass

func find_hand_node():
	# Your existing implementation
	pass

func find_node_by_name(node_name, current_node = null):
	# Your existing implementation
	pass

func debug_card_effects():
	print("\n=== DEBUGGING CARD EFFECTS ===")
	
	# Check if EffectManager exists
	var effectManager = get_node_or_null("/root/EffectManager")
	if effectManager:
		print("✅ EffectManager found")
		print("Effect definitions loaded: ", effectManager.effectDefinitions.size())
		print("Active effects: ", effectManager.activeEffects.size())
		
		for effect_name in effectManager.effectDefinitions.keys():
			print("- Effect definition: ", effect_name)
	else:
		print("❌ EffectManager not found!")
	
	# Check board state
	print("\n--- BOARD STATE ---")
	if $GameBoard:
		print("✅ GameBoard found")
		print("Board class: ", $GameBoard.get_class())
		
		# Check GlobalSignalBus.currentBoard
		print("GlobalSignalBus.currentBoard: ", GlobalSignalBus.currentBoard)
		
		if $GameBoard.has_method("getOccupiedSlots"):
			var occupiedSlots = $GameBoard.getOccupiedSlots()
			print("Occupied slots: ", occupiedSlots.size())
			
			for slot in occupiedSlots:
				var card = slot.currentCard
				if card:
					print("Card: ", card.cardName)
					print("- Type: ", card.cardType)
					print("- Effects: ", card.cardEffects)
					print("- CardId: ", card.cardId)
				else:
					print("Empty slot found")
		else:
			print("❌ GameBoard doesn't have getOccupiedSlots method")
	else:
		print("❌ GameBoard not found!")
	
	## Test BoardQueryHelper specifically
	#print("\n--- TESTING BOARD QUERY HELPER ---")
	#BoardQueryHelper.debugBoardState()
	#
	## Direct test of counting functions
	#print("Direct BoardQueryHelper tests:")
	#var woodsCount = BoardQueryHelper.countCardsOfType("location", "Woods")
	#print("BoardQueryHelper reports ", woodsCount, " Woods cards")
	#
	#var allLocations = BoardQueryHelper.countCardsOfType("location")
	#print("BoardQueryHelper reports ", allLocations, " location cards total")
	#
	#var allUnits = BoardQueryHelper.countCardsOfType("unit")
	#print("BoardQueryHelper reports ", allUnits, " unit cards total")
	#
	#print("=== END DEBUG ===\n")
