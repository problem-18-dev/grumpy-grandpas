class_name TeamSettings
extends HBoxContainer

signal teams_changed

const DEFAULT_PLAYER_AMOUNT := 3

## Team being edited. A fresh draft, not yet in GameManager, when "New team" is selected.
var _team: TeamResource

@onready var empty: Control = $Empty
@onready var existing: Control = $Existing
@onready var item_list: ItemList = %ItemList

# Adjustments
@onready var name_edit: LineEdit = %NameEdit
@onready var color_option: OptionButton = %ColorOption
@onready var player_amount: SpinBox = %PlayerAmount
@onready var player_health: SpinBox = %PlayerHealth
@onready var cpu_check: CheckButton = %CPUCheck
@onready var cpu_difficulty_option: OptionButton = %CPUDifficultyOption
@onready var remove_button: Button = %RemoveButton
@onready var confirm_button: Button = %ConfirmButton


func _ready() -> void:
	for team_color: int in TeamResource.TeamColor.values():
		color_option.add_item(TeamResource.TeamColor.keys()[team_color].capitalize(), team_color)

	for difficulty: int in TeamResource.CPUDifficulty.values():
		cpu_difficulty_option.add_item(
			TeamResource.CPUDifficulty.keys()[difficulty].capitalize(),
			difficulty,
		)

	_show_editor(not GameManager.get_teams().is_empty())


func _show_editor(is_shown: bool) -> void:
	empty.visible = not is_shown
	existing.visible = is_shown

	if is_shown:
		_refresh_list()


func _refresh_list() -> void:
	item_list.clear()

	for team in GameManager.get_teams():
		_add_row(team.name, team, _color_icon(team.get_color()))

	if not GameManager.is_full():
		_add_row("New team", _new_team())

	# Keep the edited team selected, fall back to last row when it got removed
	var row := GameManager.get_teams().find(_team)
	_select_row(row if row >= 0 else item_list.item_count - 1)


func _add_row(text: String, team: TeamResource, icon: Texture2D = null) -> void:
	var row := item_list.add_item(text, icon)
	item_list.set_item_metadata(row, team)
	item_list.set_item_tooltip_enabled(row, false)


func _color_icon(color: Color) -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([color, color])

	var icon := GradientTexture1D.new()
	icon.gradient = gradient
	icon.width = 1
	return icon


func _select_row(row: int) -> void:
	item_list.select(row)
	_team = item_list.get_item_metadata(row)

	var taken_colors := _other_teams().map(
		func(team: TeamResource) -> int:
			return team.color,
	)
	for index in color_option.item_count:
		color_option.set_item_disabled(index, index in taken_colors)

	name_edit.text = _team.name
	color_option.select(_team.color)
	player_amount.value = _team.player_resources.size()
	player_health.value = _team.player_health
	cpu_check.button_pressed = _team.is_cpu
	cpu_difficulty_option.select(_team.cpu_difficulty)
	remove_button.visible = GameManager.get_teams().has(_team)

	_update_confirm_state()


func _new_team() -> TeamResource:
	var taken_colors := GameManager.get_teams().map(
		func(t: TeamResource) -> int:
			return t.color,
	)

	var team := TeamResource.new()
	# ponytail: MAX_TEAMS == TeamColor count, so a free color exists whenever this row does
	team.color = TeamResource \
			.TeamColor \
			.values() \
			.filter(
		func(c: int) -> bool:
			return c not in taken_colors,
	) \
			.front()
	_resize_players(team, DEFAULT_PLAYER_AMOUNT)
	return team


func _resize_players(team: TeamResource, amount: int) -> void:
	team.player_resources.resize(mini(amount, team.player_resources.size()))

	var used_names := team.player_resources.map(
		func(player: PlayerResource) -> String:
			return player.name,
	)
	var free_names := PlayerResource.RANDOM_NAMES.filter(
		func(n: String) -> bool:
			return n not in used_names,
	)
	free_names.shuffle()

	while team.player_resources.size() < amount:
		var player := PlayerResource.new()
		player.name = free_names.pop_back()
		team.player_resources.append(player)


func _other_teams() -> Array:
	return GameManager.get_teams().filter(
		func(team: TeamResource) -> bool:
			return team != _team,
	)


func _update_confirm_state() -> void:
	var team_id := _sanitize_name(name_edit.text).to_lower()

	confirm_button.disabled = (
		team_id.is_empty()
		or _other_teams().any(
			func(team: TeamResource) -> bool:
				return team.get_id() == team_id,
		)
	)


## Collapses whitespace and capitalizes the first letter, keeping the rest as typed.
func _sanitize_name(text: String) -> String:
	var clean := " ".join(text.strip_edges().split(" ", false))
	return clean.left(1).to_upper() + clean.substr(1)


func _on_first_new_team_button_pressed() -> void:
	_show_editor(true)


func _on_cpu_check_toggled(toggled_on: bool) -> void:
	cpu_difficulty_option.visible = toggled_on


func _on_name_edit_text_changed(_new_text: String) -> void:
	_update_confirm_state()


func _on_remove_button_pressed() -> void:
	GameManager.remove_team(_team)
	_refresh_list()


func _on_confirm_button_pressed() -> void:
	_team.name = _sanitize_name(name_edit.text)
	_team.color = color_option.get_selected_id() as TeamResource.TeamColor
	_team.player_health = int(player_health.value)
	_team.is_cpu = cpu_check.button_pressed
	_team.cpu_difficulty = cpu_difficulty_option.get_selected_id() as TeamResource.CPUDifficulty
	_resize_players(_team, int(player_amount.value))

	if not GameManager.get_teams().has(_team):
		GameManager.add_team(_team)

	_refresh_list()

	teams_changed.emit()
