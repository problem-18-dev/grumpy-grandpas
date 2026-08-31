class_name TurnManager
extends Node2D

signal time_changed(time: int)
signal transition_started
signal transition_finished
signal turn_ended
signal turn_started

@export_group("Turn")
@export var turn_duration := 40
@export_group("Transition")
@export var transition_duration := 2

var _turn_time_remaining: int
var _transition_time_remaining: int

@onready var turn_timer: Timer = $TurnTimer
@onready var transition_timer: Timer = $TransitionTimer


func start_turn() -> void:
	_turn_time_remaining = turn_duration
	_transition_time_remaining = transition_duration
	turn_timer.start()
	time_changed.emit(_turn_time_remaining)


func finish_turn() -> void:
	turn_timer.stop()
	transition_timer.start()


func hold_turn() -> void:
	turn_timer.stop()


func _on_turn_timer_timeout() -> void:
	_turn_time_remaining -= 1

	if _turn_time_remaining < 0:
		turn_ended.emit()
		finish_turn()
		return

	time_changed.emit(_turn_time_remaining)


func _on_transition_timer_timeout() -> void:
	_transition_time_remaining -= 1

	if _transition_time_remaining < 0:
		transition_timer.stop()
		transition_finished.emit()
		return
