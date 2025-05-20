extends Node
class_name SceneManager

enum TransitionType{
	NONE,
	FADE
}

var isTransitioning: bool = false
var currentScene: Node
var pendingTransitions = []
@onready var animationPlayer: AnimationPlayer
@onready var transitionOverlay: ColorRect

func _ready():
	var canvas = CanvasLayer.new()
	canvas.name = "transitionCanvas"
	canvas.layer = 100
	add_child(canvas)
	
	transitionOverlay = ColorRect.new()
	transitionOverlay.name = "transitionOverlay"
	transitionOverlay.color = Color(0,0,0,0)
	transitionOverlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transitionOverlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	canvas.add_child(transitionOverlay)
	
	animationPlayer = AnimationPlayer.new()
	animationPlayer.name = "transitionAnimation"
	canvas.add_child(animationPlayer)
	
	animationPlayer.animation_finished.connect(onTransitionAnimationComplete)
	
	createTransitionAnimations()
	

func transitionToScene(scenePath: String, transitionType = TransitionType.NONE):
	if isTransitioning:
		pendingTransitions.append({"screen": scenePath, "type": transitionType})
		return
		
	isTransitioning = true
	
	var toScene = load(scenePath)
	if !toScene:
		push_error("sceneManager: Failed to load scene")
		isTransitioning = false
		return
	
	var targetSceneInstance = toScene.instantiate()
	
	var fromScene
	if currentScene:
		fromScene = currentScene
	else:
		fromScene = get_tree().current_scene
	
	var animationName = getTransitionAnimationName(transitionType, true)
	GlobalSignalBus.emit_signal("sceneTransitionStarted", fromScene, targetSceneInstance, transitionType)
	
	animationPlayer.play(animationName)
	await animationPlayer.animation_finished
	
	if fromScene:
		if fromScene.get_parent() == get_tree().root:
			get_tree().root.remove_child(fromScene)
		fromScene.queue_free()
	
	get_tree().root.add_child(targetSceneInstance)
	
	get_tree().current_scene = targetSceneInstance
	currentScene = targetSceneInstance
	
	var exitAnimationName = getTransitionAnimationName(transitionType, false)
	animationPlayer.play(exitAnimationName)

func getTransitionAnimationName(transitionType, isEntering: bool):
	var suffix = "_in" if isEntering else "_out"
	
	match transitionType:
		TransitionType.FADE:
			return "transitions/fade" + suffix
		TransitionType.NONE:
			return "transitions/fade" + suffix # this is a place holder and wont be used just yet
		_:
			return "transitions/fade" + suffix

func onTransitionAnimationComplete(animationName):
	isTransitioning = false
	GlobalSignalBus.emit_signal("sceneTransitionCompleted", null, currentScene, -1)
	
	if pendingTransitions.size() > 0:
		var nextTransition = pendingTransitions.pop_front()
		transitionToScene(nextTransition.scene, nextTransition.type)
	

func createTransitionAnimations():
	createFadeAnimation()

func createFadeAnimation():
	var library = AnimationLibrary.new()
	var fadeInAnimation = Animation.new()
	var trackId = fadeInAnimation.add_track(Animation.TYPE_VALUE)
	fadeInAnimation.track_set_path(trackId, "transitionOverlay:color")
	fadeInAnimation.track_insert_key(trackId, 0.0, Color(0, 0, 0, 0))
	fadeInAnimation.track_insert_key(trackId, 0.5, Color(0, 0, 0, 1.0))
	fadeInAnimation.length = 0.5
	library.add_animation("fade_in", fadeInAnimation)
	
	var fadeOutAnimation = Animation.new()
	trackId = fadeOutAnimation.add_track(Animation.TYPE_VALUE)
	fadeOutAnimation.track_set_path(trackId, "transitionOverlay:color")
	fadeOutAnimation.track_insert_key(trackId, 0.0, Color(0, 0, 0, 1.0))
	fadeOutAnimation.track_insert_key(trackId, 0.5, Color(0, 0, 0, 0))
	fadeOutAnimation.length = 0.5
	library.add_animation("fade_out", fadeOutAnimation)
	
	animationPlayer.add_animation_library("transitions", library)
