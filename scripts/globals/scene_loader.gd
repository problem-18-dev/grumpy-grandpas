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

var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []

var _active_loading_screen: LoadingScreen


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	var load_status := ResourceLoader.load_threaded_get_status(scene_path, progress)
	_active_loading_screen.set_progress(progress[0])

	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)

			await _active_loading_screen.finish()
			_active_loading_screen = null

			get_tree().change_scene_to_packed(loaded_resource)


func load_scene(scene: Scenes) -> void:
	scene_path = SCENES[scene]

	_active_loading_screen = LOADING_SCREEN.instantiate()
	add_child(_active_loading_screen)

	await _active_loading_screen.screen_ready

	_start_load()


func _start_load() -> void:
	# Makes it more fun
	await get_tree().create_timer(0.25).timeout

	var state := ResourceLoader.load_threaded_request(scene_path, "", true)

	if state == OK:
		set_process(true)
