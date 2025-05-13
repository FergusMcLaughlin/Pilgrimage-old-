extends Node


func _ready():
	$QuitButton.connect("pressed", Callable(self, "on_quit_button_pressed"))

func on_quit_button_pressed():
	print("hello")
	get_tree().quit()
