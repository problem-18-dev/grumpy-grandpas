class_name PauseOverlay
extends Control

const TEAM_PANEL_UID := "uid://db72ssn7bo0t5"

@onready var settings_container: MarginContainer = %SettingsContainer
@onready var teams_container: HBoxContainer = %TeamsContainer
@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	_render_teams()

	continue_button.grab_focus.call_deferred()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		_on_continue_button_pressed()
		get_viewport().set_input_as_handled()


func _render_teams() -> void:
	for child in teams_container.get_children():
		child.queue_free()

	for team: TeamResource in GameManager.teams:
		var team_panel: PauseTeamPanel = load(TEAM_PANEL_UID).instantiate()
		team_panel.color = team.get_color()
		team_panel.players_count = team.get_players().size()
		teams_container.add_child(team_panel)


func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_settings_button_pressed() -> void:
	settings_container.visible = not settings_container.visible


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	SceneLoader.load_scene(SceneLoader.Scenes.MENU)
