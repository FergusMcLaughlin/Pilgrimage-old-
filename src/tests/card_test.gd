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
	$Ui/ButtonPanel/FlipButton.pressed.connect(on_flip_button_pressed)
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
	print("- FlipButton connected: ", $Ui/ButtonPanel/FlipButton.is_connected("pressed", Callable(self, "on_flip_button_pressed")))
	print("- StateButton connected: ", $Ui/ButtonPanel/StateButton.is_connected("pressed", Callable(self, "on_change_state_button_pressed")))
	print("- DragButton connected: ", $Ui/ButtonPanel/DragButton.is_connected("pressed", Callable(self, "on_test_drag_button_pressed")))
	print("- MoveToSlotButton connected: ", $Ui/ButtonPanel/MoveToSlotButton.is_connected("pressed", Callable(self, "on_move_to_slot_button_pressed")))
	print("- RemoveFromSlotButton connected: ", $Ui/ButtonPanel/RemoveFromSlotButton.is_connected("pressed", Callable(self, "on_remove_from_slot_button_pressed")))
	print("- debug_button connected: ", $Ui/ButtonPanel/debug_button.is_connected("pressed", Callable(self, "on_debug_button_pressed")))
	print("- fill_board connected: ", $Ui/ButtonPanel/fill_board.is_connected("pressed", Callable(self, "on_fill_board_button_pressed")))
	print("- fill_one_slot connected: ", $Ui/ButtonPanel/fill_one_slot.is_connected("pressed", Callable(self, "on_fill_one_slot_button_pressed")))

# New function for fill_board button
func on_fill_board_button_pressed():
	print("\n----- FILL BOARD BUTTON PRESSED -----")
	
	if journeyDeck:
		print("Filling board with journey cards")
		
		# Check if we can access the grid
		if cardGrid && cardGrid.has_method("getEmptySlots"):
			var emptySlots = cardGrid.getEmptySlots()
			print("Found " + str(emptySlots.size()) + " empty slots")
			
			# Fill all empty slots
			for slot in emptySlots:
				var card = journeyDeck.drawCard()
				if card:
					journeyDeck.placeCardInSlot(card, slot)
					print("Placed card " + card.cardName + " in slot")
				else:
					print("No more cards in journey deck")
					break
		else:
			print("ERROR: Cannot find CardGrid or it lacks getEmptySlots method")
			# Try direct approach - find slots in scene
			var slots = get_tree().get_nodes_in_group("cardSlot")
			print("Found " + str(slots.size()) + " card slots via group")
			
			var emptySlots = []
			for slot in slots:
				if !slot.cardInSlot:
					emptySlots.append(slot)
			
			print("Found " + str(emptySlots.size()) + " empty slots")
			for slot in emptySlots:
				var card = journeyDeck.drawCard()
				if card:
					place_journey_card_in_slot(card, slot)
					print("Placed card " + card.cardName + " in slot")
				else:
					print("No more cards in journey deck")
					break
	else:
		print("ERROR: JourneyDeck not found or initialized")

# New function for fill_one_slot button
func on_fill_one_slot_button_pressed():
	print("\n----- FILL ONE SLOT BUTTON PRESSED -----")
	
	if journeyDeck:
		print("Filling one empty slot with journey card")
		
		# Find an empty slot
		var emptySlot = find_first_empty_slot()
		
		if emptySlot:
			print("Found empty slot at position: " + str(emptySlot.global_position))
			var card = journeyDeck.drawCard()
			
			if card:
				place_journey_card_in_slot(card, emptySlot)
				print("Placed card " + card.cardName + " in slot")
			else:
				print("No more cards in journey deck")
		else:
			print("No empty slots found on board")
	else:
		print("ERROR: JourneyDeck not found or initialized")

# Helper function to place a journey card in a slot
func place_journey_card_in_slot(card, slot):
	# Set card state
	card.setCardState(card.cardState.IN_SLOT)
	# Move card to slot position
	var tween = create_tween()
	tween.tween_property(card, "global_position", slot.global_position, 0.3)
	
	# Update slot state
	if slot.has_method("setCurrentCard"):
		slot.setCurrentCard(card)
	else:
		print("WARNING: Slot doesn't have setCurrentCard method")

# Helper function to find the first empty slot
func find_first_empty_slot():
	# Try with grid
	if cardGrid && cardGrid.has_method("getEmptySlots"):
		var emptySlots = cardGrid.getEmptySlots()
		if !emptySlots.is_empty():
			return emptySlots[0]
	
	# Direct approach - check all slots
	var slots = get_tree().get_nodes_in_group("cardSlot")
	for slot in slots:
		if !slot.cardInSlot:
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
	# Your existing implementation
	pass

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
