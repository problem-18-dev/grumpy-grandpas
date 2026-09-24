extends HBoxContainer

@export var team_settings: TeamSettings

var _team: TeamResource
var _players: Array[PlayerResource]
var _selected_player_pointer := 0
var _selected_player: PlayerResource
var _initialized := false

@onready var item_list: ItemList = %ItemList
@onready var player_name_label: Label = %PlayerNameLabel
@onready var player_texture: TextureRect = %PlayerTexture

# Adjustments
@onready var name_edit: LineEdit = %NameEdit
@onready var gender_option: OptionButton = %GenderOption
@onready var confirm_button: Button = %ConfirmButton


func _ready() -> void:
	if is_instance_valid(team_settings):
		team_settings.teams_changed.connect(_on_team_settings_teams_changed)


func _update_team_list() -> void:
	item_list.clear()

	for team in GameManager.get_teams():
		_add_row(team.name, team, _color_icon(team.get_color()))

	_select_row(0)


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
	_players = _team.player_resources
	_selected_player_pointer = 0
	_selected_player = _players[_selected_player_pointer]

	_update_fields()


func _update_fields() -> void:
	name_edit.text = _selected_player.name
	gender_option.select(PlayerResource.Gender.values()[_selected_player.gender])
	player_name_label.text = _selected_player.name
	player_texture.modulate = _team.get_color()


func _update_confirm() -> void:
	var new_name := name_edit.text.strip_edges()

	if (
		new_name.is_empty() or new_name.to_lower() == _selected_player.name.to_lower()
		or _players.any(
			func(p: PlayerResource) -> bool:
				return p.name == new_name,
		)
	):
		confirm_button.disabled = true
		return

	confirm_button.disabled = false


func _on_name_edit_text_changed(new_name: String) -> void:
	player_name_label.text = new_name
	_update_confirm()


func _on_confirm_button_pressed() -> void:
	_selected_player.name = name_edit.text
	_selected_player.gender = gender_option.get_selected_id() as PlayerResource.Gender
	_team.player_resources[_selected_player_pointer] = _selected_player
	_update_fields()
	_update_confirm()


func _on_visibility_changed() -> void:
	if not visible or _initialized:
		return

	for gender: int in PlayerResource.Gender.values():
		gender_option.add_item(PlayerResource.Gender.keys()[gender].capitalize(), gender)

	_update_team_list()


func _on_gender_option_item_selected(index: int) -> void:
	if index != _selected_player.gender:
		confirm_button.disabled = false


func _on_arrow_pressed(next: int) -> void:
	_selected_player_pointer += next
	_selected_player_pointer = wrapi(_selected_player_pointer, 0, _players.size())
	_selected_player = _players[_selected_player_pointer]
	_update_fields()
	_update_confirm()


func _on_team_settings_teams_changed() -> void:
	_update_team_list()
	_update_fields()
