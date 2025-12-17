extends "res://src/card/card.gd"

const isPlayerCard = true
var isGameOver = false

func updateCardVisuals():
	super.updateCardVisuals()
	
	if cardHealth <= 0 && !isGameOver:
		isGameOver = true
		characterDeath()

func characterDeath():
	SceneManager.transitionToScene("res://src/ui/gameOver/game_over.tscn", SceneManager.TransitionType.FADE)
