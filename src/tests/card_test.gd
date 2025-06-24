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
	
	# Add debug button for effects
	var debug_effects_button = Button.new()
	debug_effects_button.text = "Debug Effects"
	debug_effects_button.position = Vector2(10, 350)
	debug_effects_button.size = Vector2(100, 30)
	debug_effects_button.pressed.connect(debug_card_effects)
	$Ui/ButtonPanel.add_child(debug_effects_button)
	
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
	
	# Connect to effect signals for debugging
	# Since the signals are emitted on GlobalSignalBus, connect there
	if GlobalSignalBus.has_signal("effectsStarted"):
		GlobalSignalBus.effectsStarted.connect(_on_effects_started)
		print("DEBUG: Connected to effectsStarted signal on GlobalSignalBus")
	else:
		print("DEBUG: effectsStarted signal not found on GlobalSignalBus")
		
	if GlobalSignalBus.has_signal("effectsFinished"):
		GlobalSignalBus.effectsFinished.connect(_on_effects_finished)
		print("DEBUG: Connected to effectsFinished signal on GlobalSignalBus")
	else:
		print("DEBUG: effectsFinished signal not found on GlobalSignalBus")
	
	# Force a debug to see if BoardQueryHelper works now
	print("\n----- TESTING BOARD QUERY IMMEDIATELY -----")
	await get_tree().process_frame
	var testCount = BoardQueryHelper.countCardsOfType("location", "Woods")
	print("DEBUG: Immediate test - Woods count: ", testCount)

func _on_effects_started():
	print("🔴 EFFECTS STARTED - Movement blocked")

func _on_effects_finished():
	print("🟢 EFFECTS FINISHED - Movement enabled")

# New function for fill_board button using journeyDeck methods
func on_fill_board_button_pressed():
	print("\n----- FILL BOARD BUTTON PRESSED -----")
	
	if journeyDeck:
		print("Filling board with journey cards")
		# Use the journeyDeck's fillEmptySlots method
		journeyDeck.fillEmptySlots()
		
		# Debug after filling
		await get_tree().create_timer(1.0).timeout
		debug_card_effects()
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
				
				# Debug effects after placement
				await get_tree().create_timer(0.5).timeout
				debug_card_effects()
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
	debug_card_effects()

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
	print("Time: ", Time.get_ticks_msec())
	
	# First, let's check all autoload nodes
	print("\n--- CHECKING AUTOLOADS ---")
	var autoloads = [
		"/root/EffectManager",  # Changed from CardEffectManager
		"/root/GlobalSignalBus",
		"/root/GameConstants",
		"/root/CardDictionaryJsonLoader",
		"/root/CardEffectDictionaryJsonLoader"
	]
	
	for path in autoloads:
		var node = get_node_or_null(path)
		if node:
			print("✅ Found: ", path, " - Class: ", node.get_class())
		else:
			print("❌ NOT Found: ", path)
	
	# Check if EffectManager exists (note: using EffectManager, not CardEffectManager)
	var effectManager = get_node_or_null("/root/EffectManager")
	if effectManager:
		print("✅ EffectManager found")
		print("Effect definitions loaded: ", effectManager.effectDefinitions.size())
		print("Active effects: ", effectManager.activeEffects.size())
		
		# Print all loaded effect definitions
		print("\n--- EFFECT DEFINITIONS ---")
		for effect_name in effectManager.effectDefinitions.keys():
			var def = effectManager.effectDefinitions[effect_name]
			print("- ", effect_name, ":")
			print("  - Trigger: ", def.get("trigger", "none"))
			print("  - Type: ", def.get("type", "none"))
			print("  - Target: ", def.get("target_card_type", "none"), " / ", def.get("target_card_name", "none"))
		
		# Print all active effects
		print("\n--- ACTIVE EFFECTS ---")
		if effectManager.activeEffects.is_empty():
			print("❌ No active effects!")
		else:
			for effect in effectManager.activeEffects:
				if is_instance_valid(effect.hostCard):
					print("- Effect: ", effect.effectName, " on card: ", effect.hostCard.cardName)
					print("  - Host card ID: ", effect.hostCard.cardId)
					print("  - Effect data: ", effect.effectData)
				else:
					print("- Invalid effect (host card freed)")
		
		# Check timer status
		if effectManager.effectTimer:
			print("\n--- TIMER STATUS ---")
			print("Timer exists: ✅")
			print("Current batch: ", effectManager.effectTimer.currentBatch)
			print("Total batches: ", effectManager.effectTimer.batches.size())
			print("Timer running: ", !effectManager.effectTimer.timer.is_stopped())
	else:
		print("❌ CardEffectManager not found in autoload!")
	
	# Check board state
	print("\n--- BOARD STATE ---")
	if $GameBoard:
		print("✅ GameBoard found")
		print("Board class: ", $GameBoard.get_class())
		
		# Check GlobalSignalBus.currentBoard
		print("GlobalSignalBus.currentBoard: ", GlobalSignalBus.currentBoard)
		
		if $GameBoard.has_method("getOccupiedSlots"):
			var occupiedSlots = $GameBoard.getOccupiedSlots()
			print("\nOccupied slots: ", occupiedSlots.size())
			
			for i in range(occupiedSlots.size()):
				var slot = occupiedSlots[i]
				var card = slot.currentCard
				if card:
					print("\nSlot ", i, " - Card: ", card.cardName)
					print("  - Type: ", card.cardType)
					print("  - CardId: ", card.cardId)
					print("  - Effects: ", card.cardEffects)
					print("  - Attack/Health: ", card.cardAttack, "/", card.cardHealth)
					
					# Check if this card should have effects
					var cardData = CardDictionaryJsonLoader.cardData.get(card.cardId, {})
					var expectedEffects = cardData.get("effects", [])
					if !expectedEffects.is_empty():
						print("  - ⚠️ Card SHOULD have effects: ", expectedEffects)
		else:
			print("❌ GameBoard doesn't have getOccupiedSlots method")
	else:
		print("❌ GameBoard not found!")
	
	# Test triggering effects manually
	print("\n--- MANUAL EFFECT TRIGGER TEST ---")
	if effectManager:
		print("Manually calling checkEffects with 'board_changed'...")
		effectManager.checkEffects("board_changed", {})
		
		await get_tree().create_timer(0.1).timeout
		
		print("Manually calling checkEffects with 'slot_filled'...")
		effectManager.checkEffects("slot_filled", {})
	
	# Check signal connections
	print("\n--- SIGNAL CONNECTIONS ---")
	if effectManager:
		# Check if signals are connected to any callable
		var boardStateConnections = GlobalSignalBus.get_signal_connection_list("boardStateChanged")
		print("boardStateChanged has ", boardStateConnections.size(), " connections")
		for conn in boardStateConnections:
			print("  - Connected to: ", conn.callable)
		
		var slotFilledConnections = GlobalSignalBus.get_signal_connection_list("slotFilled")
		print("slotFilled has ", slotFilledConnections.size(), " connections")
		for conn in slotFilledConnections:
			print("  - Connected to: ", conn.callable)
	else:
		print("❌ Cannot check signal connections - effectManager is null")
	
	print("\n=== END DEBUG ===\n")

# Add a test to manually trigger board state change
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Press Enter/Space
		print("\n--- MANUAL BOARD STATE CHANGE ---")
		GlobalSignalBus.emit_signal("boardStateChanged")
		debug_card_effects()
