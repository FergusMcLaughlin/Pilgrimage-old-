class_name GameState

var boardState: Dictionary = {}
var playerState: Dictionary = {}
var eventHistory: Array = []

func _init():
	updateFromCurrentGameState()

func updateFromCurrentGameState():
	updateBoardState()
	updatePlayerState()

func updateBoardState():
	var board = GlobalSignalBus.currentBoard
	if !board:
		push_error("GameState: No current board found")
		return
	
	boardState = {
		"occupiedSlots": board.getOccupiedSlots(),
		"emptySlots": board.getEmptySlots(),
		"totalCards": 0,
		"cardsByType": {},
		"cardsByName": {}
	}
	
	for slot in boardState.occupiedSlots:
		var card = slot.currentCard
		if card:
			boardState.totalCards +=1
		
			var cardType = card.cardType
			if !boardState.cardsByType.has(cardType):
				boardState.cardsByType[cardType] = 0
			boardState.cardsByType[cardType] += 1
			
			var cardName = card.cardName
			if !boardState.cardsByName.has(cardName):
				boardState.cardsByName[cardName] = 0
			boardState.cardsByName[cardName] += 1

func updatePlayerState():
	var characterCard = findCharacterCard()
	if characterCard:
		playerState = {
			"currentHealth": characterCard.cardHealth,
			"maxHealth": characterCard.baseHealth,
			"currentAttack": characterCard.cardAttack,
			"baseAttack": characterCard.baseAttack
		}
	else:
		playerState = {
			"currentHealth": 0,
			"maxHealth": 0,
			"currentAttack": 0,
			"baseAttack": 0
		}

func findCharacterCard():
	if !boardState.has("occupiedSlots"):
		return null
	
	for slot in boardState.occupiedSlots:
		var card = slot.currentCard
		if card && card.get("isPlayerCard"):
			return card
	return null

func getBoardCardCount(cardType: String = "", cardName: String = ""):
	if cardName != "":
		return boardState.cardsByName.get(cardName, 0)
	elif cardType != "":
		return boardState.cardsByType.get(cardType, 0)
	else:
		return boardState.totalCards

func getPlayerHealth():
	return playerState.get("currentHealth", 0)

func getPlayerMaxHealth():
	return playerState.get("maxHealth", 0)

func getEnemyCardCount():
	var enemyCount = 0
	for slot in boardState.occupiedSlots:
		var card = slot.currentCard
		if card && card.get("isPlayerCard"):
			enemyCount += 1
	return enemyCount

#could expand for return terrain or even a get(
