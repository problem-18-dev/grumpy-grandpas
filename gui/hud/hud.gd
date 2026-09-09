class_name HUD
extends Control

@onready var message_label: Label = %MessageLabel
@onready var turn_timer_label: Label = %TurnTimerLabel


func set_message(message: String) -> void:
	message_label.text = message


func set_turn_timer(value: int) -> void:
	turn_timer_label.text = str(value)
