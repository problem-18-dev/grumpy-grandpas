extends Node

enum Scenes {
	GAME,
	TUTORIAL,
	MENU,
}

const LOADING_SCREEN := preload("uid://brt1lxrovstmi")
const SCENES := {
	Scenes.GAME: "uid://ciimkqey5k0nn",
	Scenes.TUTORIAL: "uid://sno2lalbj3mf",
	Scenes.MENU: "uid://b2d8kklebnhfj",
}

var _progress: Array[float] = []
var _loaded_resource: PackedScene
var _scene_path: String
var _loading_screen: LoadingScreen


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	var load_status := ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	_loading_screen.set_progress(_progress[0])

	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)

			await _loading_screen.finish()
			_loading_screen = null

			get_tree().change_scene_to_packed(_loaded_resource)


func load_scene(scene: Scenes) -> void:
	await get_tree().process_frame

	_scene_path = SCENES[scene]
	_loading_screen = LOADING_SCREEN.instantiate()

	get_tree().unload_current_scene()
	add_child(_loading_screen)
	await _loading_screen.screen_ready

	_start_loading()


func _start_loading() -> void:
	# Makes it more fun
	await get_tree().create_timer(0.25).timeout

	var state := ResourceLoader.load_threaded_request(_scene_path, "", true)

	if state == OK:
		set_process(true)
