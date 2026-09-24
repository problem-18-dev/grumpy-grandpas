extends HBoxContainer

const GAME_UID := "uid://ciimkqey5k0nn"


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_UID)
