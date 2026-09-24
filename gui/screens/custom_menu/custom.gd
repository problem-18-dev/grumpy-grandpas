extends Control

const MAIN_MENU_UID := "uid://b2d8kklebnhfj"

@onready var level_button: Button = %LevelButton
@onready var content_label: Label = %ContentLabel


func _on_level_button_pressed(source: Button) -> void:
	content_label.text = source.text


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_UID)
