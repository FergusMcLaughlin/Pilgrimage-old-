extends Node


func _ready():
	$QuitButton.connect("pressed", Callable(self, "on_quit_button_pressed"))
	$StartButton.connect("pressed", Callable(self, "on_start_button_pressed"))

func on_quit_button_pressed():
	print("hello")
	get_tree().quit()

func on_start_button_pressed():
	SceneTransitionManager.transitionToScene("res://src/tests/card_test.tscn", SceneTransitionManager.TransitionType.FADE)
