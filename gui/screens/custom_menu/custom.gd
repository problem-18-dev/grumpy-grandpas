extends Control

const MAIN_MENU_UID := "uid://b2d8kklebnhfj"

@onready var level_button: Button = %LevelButton
@onready var items_button: Button = %ItemsButton
@onready var players_button: Button = %PlayersButton
@onready var teams_button: Button = %TeamsButton
@onready var content_title_label: Label = %ContentTitleLabel
@onready var team_settings: TeamSettings = %TeamSettings
@onready var players_settings: HBoxContainer = %PlayersSettings
@onready var sub_menu_panel: Panel = %SubMenuPanel
@onready var sub_menus := {
	level_button: { "title": "Level", "menu": %LevelSettings },
	items_button: { "title": "Items", "menu": %ItemsSettings },
	players_button: { "title": "Players", "menu": %PlayersSettings },
	teams_button: { "title": "Teams", "menu": %TeamSettings },
}


func _ready() -> void:
	_group_buttons()
	teams_button.button_pressed = true
	_on_team_settings_teams_changed()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		_on_back_button_pressed()


func _group_buttons() -> void:
	var button_group := ButtonGroup.new()
	button_group.pressed.connect(_on_test_button_pressed)

	level_button.button_group = button_group
	items_button.button_group = button_group
	players_button.button_group = button_group
	teams_button.button_group = button_group


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_UID)


func _on_team_settings_teams_changed() -> void:
	var teams := CustomGameSaveManager.get_teams()
	players_button.disabled = teams.is_empty()
	items_button.disabled = teams.is_empty()
	level_button.disabled = teams.size() < 2


func _on_test_button_pressed(button: Button) -> void:
	for sub_menu in sub_menu_panel.get_children():
		sub_menu.hide()

	var sub_menu_data: Dictionary = sub_menus[button]
	content_title_label.text = sub_menu_data.title
	sub_menu_data.menu.show()
