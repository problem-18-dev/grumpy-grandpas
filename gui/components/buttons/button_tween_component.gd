@tool
extends Node

@export_group("Properties")
@export var duration := 0.1
@export var scale := 1.15
@export var rotation_in_deg := 2.0
@export var pressed_scale := 0.8
@export_group("Tween")
@export var trans_type := Tween.TransitionType.TRANS_BACK
@export var ease_type := Tween.EaseType.EASE_OUT

var _tween: Tween

@onready var button: Button = get_parent()


func _get_configuration_warnings() -> PackedStringArray:
	if button is not Button:
		return ["Component can only be used with a button."]

	return []


func _ready() -> void:
	button.offset_transform_enabled = true
	button.pressed.connect(_on_pressed)
	button.mouse_entered.connect(_on_mouse_hovered.bind(true))
	button.focus_entered.connect(_on_mouse_hovered.bind(true))
	button.mouse_exited.connect(_on_mouse_hovered.bind(false))
	button.focus_exited.connect(_on_mouse_hovered.bind(false))


func _clean_tween() -> void:
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween().set_ease(ease_type).set_trans(trans_type).set_parallel()


func _on_pressed() -> void:
	_clean_tween()

	var start_scale := pressed_scale * Vector2.ONE
	var end_scale := scale * Vector2.ONE
	var rotation: float = deg_to_rad(rotation_in_deg) * [-1, 1].pick_random()
	_tween.tween_property(button, "offset_transform_scale", end_scale, duration).from(start_scale)
	_tween.tween_property(button, "offset_transform_rotation", rotation, duration)


func _on_mouse_hovered(hover: bool) -> void:
	if button.disabled:
		return

	_clean_tween()

	var tween_scale := Vector2.ONE * scale if hover else Vector2.ONE
	var tween_rotation: float = deg_to_rad(rotation_in_deg) * [-1, 1].pick_random() if hover else 0

	_tween.tween_property(button, "offset_transform_scale", tween_scale, duration)
	_tween.tween_property(button, "offset_transform_rotation", tween_rotation, duration)
