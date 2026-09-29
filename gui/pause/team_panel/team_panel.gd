class_name PauseTeamPanel
extends Panel

const DISABLED_VARIANT := &"DisabledPanel"

@export var color: Color
@export var players_count: int

@onready var team_color: TextureRect = %TeamColor
@onready var players_label: Label = %PlayersLabel


func _ready() -> void:
	team_color.texture = _color_icon(color)
	players_label.text = str(players_count)

	if players_count <= 0:
		theme_type_variation = DISABLED_VARIANT


func _color_icon(_color: Color) -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([_color, _color])

	var icon := GradientTexture1D.new()
	icon.gradient = gradient
	icon.width = 1
	return icon
