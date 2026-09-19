class_name HUD
extends Control

@onready var message_label: Label = %MessageLabel
@onready var turn_timer_label: Label = %TurnTimerLabel


func set_message(message: String, duration := 0.0) -> void:
	message_label.text = message

	if duration > 0:
		await get_tree().create_timer(duration).timeout
		message_label.text = ""


func set_turn_timer(value: int) -> void:
	turn_timer_label.text = str(value)
