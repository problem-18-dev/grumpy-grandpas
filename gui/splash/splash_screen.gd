extends Control

const MAIN_MENU_UID = "uid://b2d8kklebnhfj"


func _unhandled_key_input(event: InputEvent) -> void:
	if (
		event.is_action_pressed(&"shoot") or event.is_action_pressed(&"quit")
		or event.is_action_pressed(&"confirm")
	):
		to_main_menu()


func to_main_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_UID)
