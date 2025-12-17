extends Node


func _ready():
	$QuitButton.connect("pressed", Callable(self, "on_quit_button_pressed"))
	$StartButton.connect("pressed", Callable(self, "on_start_button_pressed"))
	$CharacterButton.connect("pressed", Callable(self, "on_character_button_pressed"))

func on_quit_button_pressed():
	if SceneManager.isCurrentlyTransitioning():
		print("Transition already in progress, ignoring click")
		return
		
	get_tree().quit()

func on_start_button_pressed():
	if SceneManager.isCurrentlyTransitioning():
		print("Transition already in progress, ignoring click")
		return
		
	SceneManager.transitionToScene("res://src/tests/card_test.tscn", SceneManager.TransitionType.FADE)

func on_character_button_pressed():
	if SceneManager.isCurrentlyTransitioning():
		print("Transition already in progress, ignoring click")
		return
		
	SceneManager.transitionToScene("res://src/ui/characterSelectorMenu/character_menu.tscn", SceneManager.TransitionType.FADE)
