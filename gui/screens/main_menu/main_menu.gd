extends Control

const GAME_UID := "uid://ciimkqey5k0nn"
const TUTORIAL_UID := "uid://sno2lalbj3mf"
const CUSTOM_UID := "uid://dycjov3gqjfne"
const SETTINGS_UID := "uid://dniqe8bmxsu7q"

@onready var quickplay_button: Button = %QuickplayButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_quickplay_button_pressed() -> void:
	GamePresets.load_preset(GamePresets.Preset.QUICK_PLAY)
	get_tree().change_scene_to_file(GAME_UID)


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file(TUTORIAL_UID)


func _on_custom_button_pressed() -> void:
	get_tree().change_scene_to_file(CUSTOM_UID)


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file(SETTINGS_UID)
