extends Control

const GAME_UID := "uid://ciimkqey5k0nn"
const TUTORIAL_UID := "uid://sno2lalbj3mf"

@onready var menu: CenterContainer = %Menu


func _on_quickplay_button_pressed() -> void:
	GamePresets.load_preset(GamePresets.Preset.QUICK_PLAY)
	get_tree().change_scene_to_file(GAME_UID)


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file(TUTORIAL_UID)
