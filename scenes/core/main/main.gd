class_name Main
extends Node

enum SCENE {
	TEST,
}

@export_group("Scenes")
@export var initial_scene := SCENE.TEST

var _current_scene: Node
var _scene_paths: Dictionary[SCENE, String] = { SCENE.TEST: "uid://cd2ib37t0cgmf" }


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_scene(initial_scene)


func unload_scene() -> void:
	if not _current_scene:
		return

	_current_scene.queue_free()
	_current_scene = null


func load_scene(new_scene: SCENE) -> void:
	unload_scene()

	var scene := load(_scene_paths[new_scene])
	_current_scene = scene.instantiate()
	add_child.call_deferred(_current_scene)
