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

var transitionHelper: SceneTransitionHelper
var loadingHelper: SceneLoadingHelper

func _ready():
	setUpTransitionUI()
	initialiseHelpers()
	
func setUpTransitionUI():
	var canvas = CanvasLayer.new()
	canvas.name = "transitionCanvas"
	canvas.layer = 100
	add_child(canvas)
	
	transitionOverlay = ColorRect.new()
	transitionOverlay.name = "transitionOverlay"
	transitionOverlay.color = Color(0, 0, 0, 0)
	transitionOverlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transitionOverlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(transitionOverlay)
	
	animationPlayer = AnimationPlayer.new()
	animationPlayer.name = "transitionAnimation"
	canvas.add_child(animationPlayer)
	
	animationPlayer.animation_finished.connect(onTransitionAnimationComplete)

func initialiseHelpers():
	transitionHelper = SceneTransitionHelper.new(animationPlayer, transitionOverlay) # types not taken in here ?
	loadingHelper = SceneLoadingHelper.new()

func transitionToScene(scenePath: String, transitionType = TransitionType.NONE):
	if !loadingHelper.validateScenePath(scenePath):
		return

	if isTransitioning:
		pendingTransitions.append({"screenPath": scenePath, "type": transitionType})
		return
		
	await performSceneTransition(scenePath, transitionType)

func performSceneTransition(scenePath: String, transitionType: TransitionType):
	isTransitioning = true
	
	var targetSceneInstance = loadingHelper.loadScene(scenePath)
	if !targetSceneInstance:
		isTransitioning = false
		return
	
	var fromScene = getCurrentSceneReference()

	transitionHelper.playTransition(transitionType, true)
	await animationPlayer.animation_finished

	switchToNewScene(fromScene, targetSceneInstance)
	transitionHelper.playTransition(transitionType, false)


func getCurrentSceneReference():
	if currentScene:
		return currentScene
	else:
		return get_tree().current_scene

func switchToNewScene(fromScene: Node, toScene: Node):
	if fromScene:
		loadingHelper.cleanUpScene(fromScene)
	
	get_tree().root.add_child(toScene)
	get_tree().current_scene = toScene
	currentScene = toScene

func onTransitionAnimationComplete(animationName: String):
	if animationName.ends_with("_out"):
		isTransitioning = false
		GlobalSignalBus.emitSceneTransitionCompleted(null,currentScene,-1)

		processPendingTransitions()

func processPendingTransitions():
	if pendingTransitions.size() > 0:
		var nextTransition = pendingTransitions.pop_front()
		if nextTransition.has("scenePath") and nextTransition.has("type"):
			transitionToScene(nextTransition.scenePath, nextTransition.type)
		else:
			push_error("SceneManager: Invalid pending transition data: " + str(nextTransition))
	

func getCurrentScene():
	return currentScene

func isCurrentlyTransitioning():
	return isTransitioning

func getPendingTransitionCount():
	return pendingTransitions.size()

func clearPendingTransitions():
	pendingTransitions.clear()
