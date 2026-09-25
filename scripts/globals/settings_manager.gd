extends Node

const SAVE_PATH := "user://settings.tres"

var save: SaveResource = null


func _ready() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		save = ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		save = SaveResource.new()


func save_sfx_volume(value: float) -> void:
	save.sfx_volume = value
	ResourceSaver.save(save, SAVE_PATH)


func save_master_volume(value: float) -> void:
	save.master_volume = value
	ResourceSaver.save(save, SAVE_PATH)
