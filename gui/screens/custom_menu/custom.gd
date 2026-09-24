extends Control

const MAIN_MENU_UID := "uid://b2d8kklebnhfj"

@onready var level_button: Button = %LevelButton
@onready var items_button: Button = %ItemsButton
@onready var players_button: Button = %PlayersButton
@onready var content_label: Label = %ContentLabel
@onready var team_settings: TeamSettings = %TeamSettings
@onready var players_settings: HBoxContainer = %PlayersSettings
@onready var sub_menu_panel: Panel = %SubMenuPanel
@onready var sub_menus := {
	"teams": %TeamSettings,
	"players": %PlayersSettings,
	"level": %LevelSettings,
	"items": %ItemsSettings,
}


func _ready() -> void:
	sub_menus["teams"].show()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_UID)


func _on_team_settings_teams_changed() -> void:
	var teams := GameManager.get_teams()
	players_button.disabled = teams.is_empty()
	items_button.disabled = teams.is_empty()
	level_button.disabled = teams.size() < 2


func _on_button_pressed(sub_menu_name: String) -> void:
	content_label.text = sub_menu_name.capitalize()

	var new_sub_menu: Control = sub_menus[sub_menu_name]
	if new_sub_menu.visible:
		return

	for sub_menu in sub_menu_panel.get_children():
		sub_menu.hide()

	sub_menus[sub_menu_name].show()
