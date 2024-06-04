extends Control

var nextScene = ""
@onready var progress_bar = $ProgressBar


func _ready():
	nextScene = GlobalData.sceneToLoad
	ResourceLoader.load_threaded_request(nextScene)


func _process(delta):
	var progress = []
	ResourceLoader.load_threaded_get_status(nextScene,  progress)
	progress_bar.value = progress[0]*100
	if progress[0] == 1:
		var packedScene = ResourceLoader.load_threaded_get(nextScene)
		get_tree().change_scene_to_packed(packedScene)
