extends HBoxContainer

const GAME_UID := "uid://ciimkqey5k0nn"
const LEVELS := {
	Game.Level.MORNING: { "name": "Morning", "texture_uid": "uid://dcym3af315ake" },
	Game.Level.AFTERNOON: {
		"name": "Afternoon",
		"texture_uid": "uid://dcym3af315ake",
		"custom_color": Color(0.961, 0.537, 0.192, 1.0),
	},
	Game.Level.EVENING: { "name": "Evening", "texture_uid": "uid://ddtimfe8p578h" },
}

var _level := Game.Level.MORNING

@onready var level_title_label: Label = %LevelTitleLabel
@onready var texture_rect: TextureRect = %TextureRect


func _ready() -> void:
	_update()


func _update() -> void:
	level_title_label.text = LEVELS[_level].name.capitalize()
	texture_rect.texture = load(LEVELS[_level].texture_uid)

	if LEVELS[_level].has("custom_color"):
		texture_rect.modulate = LEVELS[_level].custom_color
	else:
		texture_rect.modulate = Color.WHITE


func _on_play_button_pressed() -> void:
	CustomGameSaveManager.set_level(_level)

	var game_data := CustomGameSaveManager.get_all()
	GameConfigurator.load_custom(game_data.teams, game_data.catalogue, game_data.level)

	get_tree().change_scene_to_file(GAME_UID)


func _on_arrow_pressed(next: int) -> void:
	_level += next
	_level = wrapi(_level, 0, LEVELS.size())
	_update()
