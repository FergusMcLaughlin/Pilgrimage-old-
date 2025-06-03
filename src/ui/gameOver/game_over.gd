extends Node


func _ready():
	$RestartButton.connect("pressed", Callable(self, "on_restart_button_pressed"))
	$MenuButton.connect("pressed", Callable(self, "on_menu_button_pressed"))
	$QuitButton.connect("pressed", Callable(self, "on_quit_button_pressed"))

func on_restart_button_pressed():
	if SceneTransitionManager.isCurrentlyTransitioning():
		print("Transition already in progress, ignoring click")
		return
		
	SceneTransitionManager.transitionToScene("res://src/tests/card_test.tscn", SceneTransitionManager.TransitionType.FADE)

func on_menu_button_pressed():
	if SceneTransitionManager.isCurrentlyTransitioning():
		print("Transition already in progress, ignoring click")
		return
		
	SceneTransitionManager.transitionToScene("res://src/ui/mainMenu/main_menu.tscn", SceneTransitionManager.TransitionType.FADE)

func on_quit_button_pressed():
	if SceneTransitionManager.isCurrentlyTransitioning():
		print("Transition already in progress, ignoring click")
		return
		
	get_tree().quit()
