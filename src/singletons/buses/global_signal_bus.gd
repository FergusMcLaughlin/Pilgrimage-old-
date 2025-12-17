# GlobalSignalBus.gd - Add to autoload
extends Node
# ==============================================
# CARD SIGNALS
# ==============================================
# Input and interaction signals
signal cardClicked(card)        # When a card receives a click
signal cardHovered(card)        # When mouse enters a card
signal cardUnhovered(card)      # When mouse exits a card
# Dragging signals
signal cardDragStarted(card)    # When card starts being dragged
signal cardDragging(card, position)  # While card is being dragged
signal cardDragEnded(card, position) # When drag operation ends
# State change signals
signal cardStateChanged(card, oldState, newState)  # Card state changes
signal cardFlipped(card)        # When card is flipped
signal cardReturnedToHand(card) # When card returns to hand
# ==============================================
# CARD SLOT SIGNALS
# ==============================================
# Input signals
signal slotClicked(slot)        # When a slot is clicked
signal slotHovered(slot)        # When mouse enters a slot
signal slotUnhovered(slot)      # When mouse exits a slot
# State change signals
signal slotFilled(slot, card)   # When a card is placed in a slot
signal slotEmptied(slot)        # When a card is removed from a slot
# Card placement results
signal cardPlaced(card, slot)   # When card is successfully placed
signal cardPlacementFailed(card) # When card placement fails
# ==============================================
# DECK SIGNALS
# ==============================================
signal cardDrawn(card)          # When a card is drawn from deck
signal deckShuffled(deck)       # When a deck is shuffled
signal deckEmptied(deck)        # When a deck has no more cards
signal deckClicked(deck)        # When a deck is clicked
# Player deck
signal cardDrawnToHand(card)
# ==============================================
# BOARD SIGNALS
# ==============================================
signal boardStateChanged()      # When board state changes
signal boardSetup()             # When board is initially set up
signal turnStarted(turnNumber)  # When a new turn begins
signal turnEnded(turnNumber)    # When current turn ends
# ==============================================
# GAME CONTROLLER SIGNALS
# ==============================================
signal battleCompleted(attacker, defender, result)
signal cardMoved(card, fromSlot, toSlot)
signal cardDamaged(card, amount, newHealth)
# ==============================================
# SCENE MANAGER SIGNALS
# ==============================================
signal sceneTransitionStarted(fromScene, toScene, transitionType)
signal sceneTransitionCompleted(fromScene, toScene, transitionType)
