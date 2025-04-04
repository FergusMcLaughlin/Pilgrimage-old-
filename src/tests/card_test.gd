extends Node2D
var current_test_card = null

func _ready():
	# Create a test card
	spawn_test_card()
	
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
	
	# Verify button connections
	print("\nButton connections:")
	print("- FlipButton connected: ", $Ui/ButtonPanel/FlipButton.is_connected("pressed", Callable(self, "on_flip_button_pressed")))
	print("- StateButton connected: ", $Ui/ButtonPanel/StateButton.is_connected("pressed", Callable(self, "on_change_state_button_pressed")))
	print("- DragButton connected: ", $Ui/ButtonPanel/DragButton.is_connected("pressed", Callable(self, "on_test_drag_button_pressed")))
	print("- MoveToSlotButton connected: ", $Ui/ButtonPanel/MoveToSlotButton.is_connected("pressed", Callable(self, "on_move_to_slot_button_pressed")))
	print("- RemoveFromSlotButton connected: ", $Ui/ButtonPanel/RemoveFromSlotButton.is_connected("pressed", Callable(self, "on_remove_from_slot_button_pressed")))
	print("- debug_button connected: ", $Ui/ButtonPanel/debug_button.is_connected("pressed", Callable(self, "on_debug_button_pressed")))

# Helper function to print the scene tree for debugging
func print_scene_tree(node = null, indent = ""):
	if node == null:
		node = self
		print("Scene tree structure:")
	
	print(indent + node.name + " (" + node.get_class() + ")")
	
	for child in node.get_children():
		print_scene_tree(child, indent + "  ")

func spawn_test_card():
	print("\n----- SPAWNING TEST CARD -----")
	# First, ensure TestCard node exists - create it if it doesn't
	var test_card_container
	if has_node("TestCard"):
		test_card_container = $TestCard
		print("TestCard node found")
	else:
		test_card_container = Node2D.new()
		test_card_container.name = "TestCard"
		add_child(test_card_container)
		print("TestCard node created")
	
	# Remove any existing test card
	for child in test_card_container.get_children():
		child.queue_free()
		print("Removed existing card from TestCard container")
	
	# Use CreateCard autoload to create a card
	current_test_card = CreateCard.createCard("0004")
	
	# Debug: Check if card was created
	if current_test_card:
		print("Card created successfully with ID: ", current_test_card.cardId)
		print("Card properties:")
		print("- currentState: ", current_test_card.currentState)
		print("- has cardState enum: ", current_test_card.get("cardState") != null)
		print("- has setCardState method: ", current_test_card.has_method("setCardState"))
	else:
		push_error("Failed to create test card with ID: 0004")
		return
	
	test_card_container.add_child(current_test_card)
	print("Card added to TestCard container")
	
	# Position it in the center of the screen
	var viewport_size = get_viewport_rect().size
	current_test_card.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
	print("Card positioned at: ", current_test_card.position)
	
	# Force high visibility for testing
	current_test_card.z_index = 10
	
	# Force update card visuals
	current_test_card.updateCardVisuals()
	print("Card visuals updated")

func on_flip_button_pressed():
	print("\n----- FLIP BUTTON PRESSED -----")
	if current_test_card:
		print("Flipping card")
		current_test_card.flipCard()
	else:
		print("ERROR: No test card available to flip!")

func on_change_state_button_pressed():
	print("\n----- STATE BUTTON PRESSED -----")
	if current_test_card:
		# Cycle through states
		var next_state = (current_test_card.currentState + 1) % 3
		print("Changing card state from ", current_test_card.currentState, " to ", next_state)
		current_test_card.setCardState(next_state)
	else:
		print("ERROR: No test card available to change state!")

func on_test_drag_button_pressed():
	print("\n----- DRAG BUTTON PRESSED -----")
	if current_test_card:
		# Make sure we have a valid viewport
		if get_viewport():
			print("Starting drag test")
			var drag_offset = current_test_card.handleCardDrag()
			print("Drag initiated with offset: ", drag_offset)
			
			# For testing, we'll manually simulate the end of dragging after 2 seconds
			print("Waiting 2 seconds before ending drag...")
			await get_tree().create_timer(2.0).timeout
			current_test_card.setCardState(current_test_card.cardState.ON_BOARD)
			print("Drag test completed")
		else:
			push_error("Cannot get viewport for drag operation!")
	else:
		print("ERROR: No test card available to drag!")

func on_move_to_slot_button_pressed():
	print("\n----- MOVE TO SLOT BUTTON PRESSED -----")
	
	# Check if card exists
	if !current_test_card:
		print("ERROR: No test card available!")
		return
	
	# First check for CardSlot (name from your scene tree)
	if has_node("CardSlot"):
		print("Found CardSlot node")
		var slot = $CardSlot
		move_card_to_slot(slot)
	# Then check for TestSlot (name used in your original code)
	elif has_node("TestSlot"):
		print("Found TestSlot node")
		var slot = $TestSlot
		move_card_to_slot(slot)
	else:
		print("ERROR: No CardSlot or TestSlot found in scene!")
		print("Available nodes at root level:")
		for child in get_children():
			print("- ", child.name)

# Helper function to move card to a slot
func move_card_to_slot(slot):
	print("Moving card to slot at position: ", slot.position)
	
	# Debug slot properties
	print("Slot properties:")
	print("- has currentCard property: ", slot.get("currentCard") != null)
	print("- has setCurrentCard method: ", slot.has_method("setCurrentCard"))
	
	# Move card to slot position
	var tween = create_tween()
	tween.tween_property(current_test_card, "position", slot.position, 0.3)
	print("Tween started")
	
	# Use a timer instead of await for guaranteed execution
	var timer = get_tree().create_timer(0.4)
	timer.timeout.connect(func():
		print("Tween should be finished")
		
		# Set card state
		if current_test_card.has_method("setCardState") && current_test_card.get("cardState"):
			current_test_card.setCardState(current_test_card.cardState.ON_BOARD)
			print("Card state set to ON_BOARD")
		else:
			print("ERROR: Could not set card state (missing method or enum)")
		
		# Update slot
		if slot.has_method("setCurrentCard"):
			slot.setCurrentCard(current_test_card)
			print("Called setCurrentCard on slot")
		else:
			print("ERROR: Slot missing setCurrentCard method!")
	)

func on_remove_from_slot_button_pressed():
	print("\n----- REMOVE FROM SLOT BUTTON PRESSED -----")
	
	# Check if card exists
	if !current_test_card:
		print("ERROR: No test card available!")
		return
	
	# First check for CardSlot (name from your scene tree)
	if has_node("CardSlot"):
		print("Found CardSlot node")
		var slot = $CardSlot
		remove_card_from_slot(slot)
	# Then check for TestSlot (name used in your original code)
	elif has_node("TestSlot"):
		print("Found TestSlot node") 
		var slot = $TestSlot
		remove_card_from_slot(slot)
	else:
		print("ERROR: No CardSlot or TestSlot found in scene!")

# Helper function to remove card from a slot
func remove_card_from_slot(slot):
	print("Checking if card is in slot")
	print("Slot currentCard: ", slot.currentCard)
	print("Current test card: ", current_test_card)
	
	# Only proceed if this card is in the slot
	if slot.currentCard == current_test_card:
		print("Card is in slot, clearing...")
		
		# Clear the slot
		if slot.has_method("clearSlot"):
			slot.clearSlot()
			print("Called clearSlot on slot")
		else:
			print("ERROR: Slot missing clearSlot method!")
		
		# Move card back to center
		var viewport_size = get_viewport_rect().size
		var tween = create_tween()
		tween.tween_property(current_test_card, "position", Vector2(viewport_size.x / 2, viewport_size.y / 2), 0.3)
		print("Moving card back to center")
		
		# Use a timer instead of await for guaranteed execution
		var timer = get_tree().create_timer(0.4)
		timer.timeout.connect(func():
			# Update card state
			if current_test_card.has_method("setCardState") && current_test_card.get("cardState"):
				current_test_card.setCardState(current_test_card.cardState.IN_HAND)
				print("Card state set to IN_HAND")
			else:
				print("ERROR: Could not set card state (missing method or enum)")
		)
	else:
		print("Card is not in this slot!")
		print("Slot's current card: ", slot.currentCard)
		print("Current test card: ", current_test_card)

# Debug function for the debug_button
func on_debug_button_pressed():
	print("\n----- DEBUGGING ALL CARDS IN SCENE -----")
	
	# Get all cards in the scene
	var allCards = get_tree().get_nodes_in_group("cards")
	if allCards.size() == 0:
		# If there are no cards in the group, try to find them manually
		allCards = find_all_cards_in_scene()
	
	print("Found " + str(allCards.size()) + " cards in scene")
	
	# Debug current test card if it exists
	if current_test_card:
		print("\nCurrent test card:")
		print_card_debug_info(current_test_card)
	
	# Debug all cards in the scene
	if allCards.size() > 0:
		print("\nAll cards in scene:")
		for card in allCards:
			print_card_debug_info(card)
	
	# Debug card in hands
	var hand = find_hand_node()
	if hand:
		print("\nHand info:")
		print("Hand node found at: " + str(hand.get_path()))
		if hand.has_method("getCards") && hand.has_method("getCardCount"):
			print("Cards in hand: " + str(hand.getCardCount()))
			var cardsInHand = hand.getCards()
			for card in cardsInHand:
				print("  - Card in hand: " + card.cardName + " (ID: " + card.cardId + ")")
	
	# Debug card slots
	var slots = get_tree().get_nodes_in_group("cardSlot")
	print("\nFound " + str(slots.size()) + " card slots")
	for slot in slots:
		print("Slot at position: " + str(slot.global_position))
		print("  - Has card: " + str(slot.cardInSlot))
		if slot.currentCard:
			print("  - Card: " + slot.currentCard.cardName + " (ID: " + slot.currentCard.cardId + ")")
	
	print("--------------------------------------\n")

# Helper function to print detailed card info
func print_card_debug_info(card):
	# Get state name
	var stateName = "Unknown"
	match card.currentState:
		card.cardState.ON_BOARD: stateName = "ON_BOARD"
		card.cardState.IN_DECK: stateName = "IN_DECK"
		card.cardState.IN_HAND: stateName = "IN_HAND"
		card.cardState.BEING_DRAGGED: stateName = "BEING_DRAGGED"
	
	# Get parent info
	var parentName = "None"
	var location = "Unknown"
	var parent = card.get_parent()
	if parent:
		parentName = parent.name
		if parent.name == "Hand" || (parent.has_method("getCards") && parent.has_method("getCardCount")):
			location = "Hand"
		elif parent.name == "CardSlot" || parent.is_in_group("cardSlot"):
			location = "Slot"
		elif parent.name == "Deck" || "Deck" in parent.name:
			location = "Deck"
		else:
			location = parent.name
	
	# Print detailed info
	print("Card: " + card.cardName + " (ID: " + card.cardId + ")")
	print("  • State: " + stateName + " (" + str(card.currentState) + ")")
	print("  • Visual Properties:")
	print("    - Scale: " + str(card.scale))
	print("    - Z-Index: " + str(card.z_index))
	print("    - Position: " + str(card.global_position))
	print("  • Parent: " + parentName + " (Location: " + location + ")")
	
	# Detect potential issues
	if card.currentState != card.cardState.BEING_DRAGGED && card.scale.x > 1.01:
		print("  • ⚠️ POTENTIAL ISSUE: Card appears to be in hover state but isn't being dragged!")
	
	# Debug area2D if exists
	if card.has_node("Area2D"):
		var area = card.get_node("Area2D")
		print("  • Area2D:")
		print("    - Collision Layer: " + str(area.collision_layer))
		print("    - Collision Mask: " + str(area.collision_mask))
		if area.has_node("CollisionShape2D"):
			print("    - Collision Enabled: " + str(!area.get_node("CollisionShape2D").disabled))

# Helper function to find all cards in the scene manually
func find_all_cards_in_scene():
	print("Searching for cards manually (not in group)...")
	var foundCards = []
	
	# First check current test card
	if current_test_card && current_test_card.has_method("setCardState"):
		foundCards.append(current_test_card)
		print("Found test card: " + current_test_card.cardName)
	
	# Look for cards in the Hand node
	var hand = find_hand_node()
	if hand && hand.has_method("getCards"):
		var cardsInHand = hand.getCards()
		for card in cardsInHand:
			if !foundCards.has(card):
				foundCards.append(card)
				print("Found card in hand: " + card.cardName)
	
	# Look for cards in CardSlot nodes
	var slots = get_tree().get_nodes_in_group("cardSlot")
	for slot in slots:
		if slot.currentCard && !foundCards.has(slot.currentCard):
			foundCards.append(slot.currentCard)
			print("Found card in slot: " + slot.currentCard.cardName)
	
	return foundCards

# Helper function to find the Hand node
func find_hand_node():
	if has_node("Hand"):
		return $Hand
	
	# Search for Hand in children
	for child in get_children():
		if child.name == "Hand" || (child.has_method("getCards") && child.has_method("getCardCount")):
			return child
			
	# If not found, search recursively
	return find_node_by_name("Hand")

# Helper function to find node by name recursively
func find_node_by_name(node_name, current_node = null):
	if current_node == null:
		current_node = self
		
	if current_node.name == node_name:
		return current_node
		
	for child in current_node.get_children():
		var result = find_node_by_name(node_name, child)
		if result:
			return result
			
	return null
