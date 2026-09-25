class_name HUD
extends Control

const WHITE_COLOR := Color(1.0, 1.0, 1.0, 1.0)

@onready var message_label: Label = %MessageLabel
@onready var turn_timer_label: Label = %TurnTimerLabel
@onready var turn_timer_panel: Panel = $MarginContainer/TurnTimerPanel


func set_message(message: String, duration := 0.0, color := WHITE_COLOR) -> void:
	message_label.text = message
	message_label.add_theme_color_override("font_color", color)

	if duration > 0:
		await get_tree().create_timer(duration).timeout
		message_label.text = ""
		message_label.remove_theme_color_override("font_color")


func set_turn_timer(value: int) -> void:
	turn_timer_panel.show()
	turn_timer_label.text = str(value)
