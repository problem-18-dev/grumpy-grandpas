@tool
class_name DamageIndicator
extends Control

signal finished

const THEME_TYPE := "DamageIndicatorLabel"
const NEGATIVE_COLOR := Color(1.0, 0.118, 0.0, 1.0)
const POSITIVE_COLOR := Color(0.0, 1.0, 0.05, 1.0)

@export_group("Float")
@export var float_duration := 1.5
@export var float_height := 10.0
@export_group("Count")
@export var count_duration := 3.0
@export_group("Testing")
@export_tool_button("Display") var display_action = display

var _label: Label


func display(amount := 50) -> void:
	_label = Label.new()
	_label.theme_type_variation = THEME_TYPE
	_label.add_theme_color_override("font_color", NEGATIVE_COLOR if amount < 0 else POSITIVE_COLOR)
	_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(_label)

	var float_position := _label.position.y - float_height
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_parallel()
	tween.set_trans(Tween.TRANS_QUINT).tween_property(
		_label,
		"position:y",
		float_position,
		float_duration,
	)
	tween.set_trans(Tween.TRANS_EXPO).tween_method(_set_text, 0, amount, count_duration)
	tween.chain().tween_callback(_label.queue_free)
	await tween.finished
	finished.emit()


func _set_text(value: int) -> void:
	var symbol := "-" if value < 0 else "+"
	_label.text = symbol + str(absi(value))
