extends HBoxContainer

const GAME_UID := "uid://ciimkqey5k0nn"
const LEVELS := ["Jungle", "Gaming Hills", "Idk Name"]

var _pointer := 0

@onready var level_title_label: Label = %LevelTitleLabel


func _ready() -> void:
	_update_title()


func _update_title() -> void:
	level_title_label.text = LEVELS[_pointer].capitalize()


func _on_play_button_pressed() -> void:
	CustomGameSaveManager.set_level(LEVELS[_pointer])

	var game_data := CustomGameSaveManager.get_all()
	GameConfigurator.load_custom(game_data.teams, game_data.catalogue)

	get_tree().change_scene_to_file(GAME_UID)


func _on_arrow_pressed(next: int) -> void:
	_pointer += next
	_pointer = wrapi(_pointer, 0, LEVELS.size())
	level_title_label.text = LEVELS[_pointer].capitalize()
