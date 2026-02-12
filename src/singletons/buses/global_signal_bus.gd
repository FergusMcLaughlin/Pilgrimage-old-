# GlobalSignalBus.gd (Autoload)
extends Node

# =========================================================
# Signals = contract
# - Declare all signals here.
# - Nobody else should use emit_signal("string", ...) directly.
# - Prefer calling the emit_* wrappers below.
# =========================================================

# ------------------------------
# CARD SIGNALS
# ------------------------------
signal cardClicked(card)
signal cardHovered(card)
signal cardUnhovered(card)

signal cardDragStarted(card)
signal cardDragging(card, position)
signal cardDragEnded(card, position)

signal cardStateChanged(card, oldState, newState)
signal cardFlipped(card)
signal cardReturnedToHand(card)

signal cardPlayed
signal cardPlacementInvalid

# ------------------------------
# SLOT SIGNALS
# ------------------------------
signal slotClicked(slot)
signal slotHovered(slot)
signal slotUnhovered(slot)

signal slotFilled(slot, card)
signal slotEmptied(slot)

signal cardPlaced(card, slot)
signal cardPlacementFailed(card)

# ------------------------------
# DECK SIGNALS
# ------------------------------
signal cardDrawn(card)
signal deckShuffled(deck)
signal deckEmptied(deck)
signal deckClicked(deck)

signal cardDrawnToHand(card)

# ------------------------------
# BOARD SIGNALS
# ------------------------------
signal boardStateChanged()
signal boardSetup()

# ------------------------------
# GAME CONTROLLER SIGNALS
# ------------------------------
signal battleCompleted(attacker, defender, result)
signal cardMoved(card, fromSlot, toSlot)
signal cardDamaged(card, amount, newHealth)

# ------------------------------
# SCENE MANAGER SIGNALS
# ------------------------------
signal sceneTransitionStarted(fromScene, toScene, transitionType)
signal sceneTransitionCompleted(fromScene, toScene, transitionType)

# =========================================================
# Emit wrappers (so other classes never type signal names)
# =========================================================

# CARD
func emitCardClicked(card) -> void:
	emit_signal("cardClicked", card)

func emitCardHovered(card) -> void:
	emit_signal("cardHovered", card)

func emitCardUnhovered(card) -> void:
	emit_signal("cardUnhovered", card)

func emitCardDragStarted(card) -> void:
	emit_signal("cardDragStarted", card)

func emitCardDragging(card, position: Vector2) -> void:
	emit_signal("cardDragging", card, position)

func emitCardDragEnded(card, position: Vector2) -> void:
	emit_signal("cardDragEnded", card, position)

func emitCardStateChanged(card, old_state, new_state) -> void:
	emit_signal("cardStateChanged", card, old_state, new_state)

func emitCardFlipped(card) -> void:
	emit_signal("cardFlipped", card)

func emitCardReturnedToHand(card) -> void:
	emit_signal("cardReturnedToHand", card)

func emitCardPlayed(card, slot) -> void:
	emit_signal("cardPlayed", card, slot)

func emitCardPlacementInvalid(card, slot) -> void:
	emit_signal("cardPlacementInvalid", card, slot)

# SLOT
func emitSlotClicked(slot) -> void:
	emit_signal("slotClicked", slot)

func emitSlotHovered(slot) -> void:
	emit_signal("slotHovered", slot)

func emitSlotUnhovered(slot) -> void:
	emit_signal("slotUnhovered", slot)

func emitSlotFilled(slot, card) -> void:
	emit_signal("slotFilled", slot, card)

func emitSlotEmptied(slot) -> void:
	emit_signal("slotEmptied", slot)

func emitCardPlaced(card, slot) -> void:
	emit_signal("cardPlaced", card, slot)

func emitCardPlacementFailed(card) -> void:
	emit_signal("cardPlacementFailed", card)

# DECK
func emitCardDrawn(card) -> void:
	emit_signal("cardDrawn", card)

func emitDeckShuffled(deck) -> void:
	emit_signal("deckShuffled", deck)

func emitDeckEmptied(deck) -> void:
	emit_signal("deckEmptied", deck)

func emitDeckClicked(deck) -> void:
	emit_signal("deckClicked", deck)

func emitCardDrawnToHand(card) -> void:
	emit_signal("cardDrawnToHand", card)

# BOARD
func emitBoardStateChanged() -> void:
	emit_signal("boardStateChanged")

func emitBoardSetup() -> void:
	emit_signal("boardSetup")

func emitTurnStarted(turn_number: int) -> void:
	emit_signal("turnStarted", turn_number)

func emitTurnEnded(turn_number: int) -> void:
	emit_signal("turnEnded", turn_number)

# GAME
func emitBattleCompleted(attacker, defender, result) -> void:
	emit_signal("battleCompleted", attacker, defender, result)

func emitCardMoved(card, from_slot, to_slot) -> void:
	emit_signal("cardMoved", card, from_slot, to_slot)

func emitCardDamaged(card, amount: int, new_health: int) -> void:
	emit_signal("cardDamaged", card, amount, new_health)

# SCENE
func emitSceneTransitionStarted(from_scene, to_scene, transition_type) -> void:
	emit_signal("sceneTransitionStarted", from_scene, to_scene, transition_type)

func emitSceneTransitionCompleted(from_scene, to_scene, transition_type) -> void:
	emit_signal("sceneTransitionCompleted", from_scene, to_scene, transition_type)
