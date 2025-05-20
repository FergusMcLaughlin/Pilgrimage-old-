extends "res://src/card/card.gd"

const isPlayerCard = true

func updateCardVisuals():
	super.updateCardVisuals()
	
	if cardHealth <= 0:
		await get_tree().create_timer(0.5).timeout
		characterDeath()

func characterDeath():
	SceneTransitionManager.transitionToScene("res://src/ui/gameOver/game_over.tscn", SceneTransitionManager.TransitionType.FADE)
