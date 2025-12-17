class_name SceneTransitionHelper

const FADE_DURATION = 0.5

var animationPlayer: AnimationPlayer
var transitionOverlay: ColorRect

func _init(player: AnimationPlayer, overlay: ColorRect):
	animationPlayer = player
	transitionOverlay = overlay
	createAllTransitionAnimations()

func createAllTransitionAnimations():
	createFadeAnimation()
	#add more animation types here

func createFadeAnimation():
	var library = AnimationLibrary.new()    
	var fadeInAnimation = Animation.new()
	var trackId = fadeInAnimation.add_track(Animation.TYPE_VALUE)
	fadeInAnimation.track_set_path(trackId, "transitionOverlay:color")
	fadeInAnimation.track_insert_key(trackId, 0.0, Color(0, 0, 0, 0))
	fadeInAnimation.track_insert_key(trackId, 0.5, Color(0, 0, 0, 1.0))
	fadeInAnimation.length = FADE_DURATION
	library.add_animation("fade_in", fadeInAnimation)

	var fadeOutAnimation = Animation.new()
	trackId = fadeOutAnimation.add_track(Animation.TYPE_VALUE)
	fadeOutAnimation.track_set_path(trackId, "transitionOverlay:color")
	fadeOutAnimation.track_insert_key(trackId, 0.0, Color(0, 0, 0, 1.0))
	fadeOutAnimation.track_insert_key(trackId, 0.5, Color(0, 0, 0, 0))
	fadeOutAnimation.length = FADE_DURATION
	library.add_animation("fade_out", fadeOutAnimation)

	animationPlayer.add_animation_library("transitions", library)

func getTransitionAnimationName(transitionType: SceneManager.TransitionType, isEntering: bool):
	var suffix = "_in" if isEntering else "_out"
	
	match transitionType:
		SceneManager.TransitionType.FADE:
			return "transitions/fade" + suffix
		SceneManager.TransitionType.NONE:
			return "transitions/fade" + suffix # this is a place holder and wont be used just yet
		_:
			return "transitions/fade" + suffix

func playTransition(transitionType: SceneManager.TransitionType, isEntering: bool):
	var animationName = getTransitionAnimationName(transitionType, isEntering)

	if animationPlayer.has_animation(animationName):
		animationPlayer.play(animationName)
	else:
		push_error("SceneTransitionHelper: Animation not found: " + animationName)
