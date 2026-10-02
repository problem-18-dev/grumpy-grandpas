class_name TurnManager
extends Node

signal time_changed(time: int, is_urgent: bool)
signal transition_started
signal transition_finished
signal turn_ended
signal turn_started

@export_group("Turn")
@export var turn_duration := 25
@export var urgent_below := 8
@export_group("Transition")
@export var transition_duration := 2.0

var _turn_time_remaining: int
var _transition_time_remaining: float
var _transitioning := false

@onready var turn_timer: Timer = $TurnTimer
@onready var transition_timer: Timer = $TransitionTimer


func reset() -> void:
	_transitioning = false
	_turn_time_remaining = turn_duration
	_transition_time_remaining = transition_duration
	turn_timer.stop()
	transition_timer.stop()


func start_turn() -> void:
	reset()
	turn_timer.start()
	time_changed.emit(_turn_time_remaining, false)


func finish_turn() -> void:
	if _transitioning:
		return

	_transitioning = true
	turn_timer.stop()
	transition_timer.start()


func hold_turn() -> void:
	if _transitioning:
		return

	turn_timer.stop()


func _on_turn_timer_timeout() -> void:
	_turn_time_remaining -= 1

	if _turn_time_remaining < 0:
		turn_ended.emit()
		finish_turn()
		return

	time_changed.emit(_turn_time_remaining, _turn_time_remaining < urgent_below)


func _on_transition_timer_timeout() -> void:
	_transition_time_remaining -= transition_timer.wait_time

	if _transition_time_remaining < 0:
		transition_timer.stop()
		transition_finished.emit()
		return
