class_name SceneLoadingHelper

func loadScene(scenePath: String):
	if !ResourceLoader.exists(scenePath):
		push_error("SceneLoadingHelper: could not get scene file: " + scenePath)
		return null
	
	var sceneResource = load(scenePath)
	if !sceneResource:
		push_error("SceneLoadingHelper: faild to load the scene resource: " + scenePath)
		return null

	if !sceneResource is PackedScene:
		push_error("SceneLoadingHelper: resource is not a packed scene: " +  scenePath)
		return null
	
	var sceneInstance = sceneResource.instantiate()
	if !sceneInstance:
		push_error("SceneLoadingHelper: failed to instanciate scene: " + scenePath)
		return null
	
	return sceneInstance

func validateScenePath(scenePath: String):
	if scenePath.is_empty():
		push_error("SceneLoadingHelper: scene path is empty.")
		return false
	
	if !scenePath.ends_with(".tscn"):
		push_error("SceneLoadingHelper: invalid file type.")
		return false
	
	return true

func cleanUpScene(scene: Node):
	if !scene:
		return
	
	if scene.get_parent():
		scene.get_parent().remove_child(scene)

	scene.queue_free()
