class_name SettingsSaveResource
extends Resource

const SAVE_PATH := "user://settings.res"

@export_group("Audio")
@export var master_volume := 1.0
@export var sfx_volume := 1.0
@export var music_volume := 0.4
@export var gui_volume := 0.6
