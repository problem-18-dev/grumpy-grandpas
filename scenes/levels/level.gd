extends Node2D

@export_group("Turns")
@export var turn_duration := 40

@onready var spawn_generator: SpawnGenerator = $SpawnGenerator
@onready var match_manager: MatchManager = $MatchManager
@onready var busy_manager: BusyManager = $BusyManager
@onready var pickuppable_manager: PickuppableManager = $PickuppableManager
@onready var announcement_label: Label = $CanvasLayer/AnnouncementLabel
@onready var time_label: Label = $CanvasLayer/TimeLabel
@onready var turn_timer: Timer = $TurnTimer
@onready var turn_time_remaining := turn_duration:
	set(time_remaining):
		turn_time_remaining = time_remaining
		time_label.text = str(turn_time_remaining)


func _ready() -> void:
	var spawn_points := spawn_generator.generate_spawn_points()
	match_manager.initiate_match(spawn_points)


func _start_turn() -> void:
	busy_manager.reset()
	await pickuppable_manager.attempt_spawn()
	match_manager.next_turn()


func _end_turn() -> void:
	match_manager.finish_turn()
	turn_timer.stop()


func _on_pickuppable_manager_picked_up(by: Player, type: PickuppableResource.Type) -> void:
	match_manager.unlock_item(by, type)


func _on_match_manager_match_ended(winner: TeamResource) -> void:
	if winner:
		announcement_label.text = "%s has won the game!" % winner.name
		return

	announcement_label.text = "It's a tie!"


func _on_match_manager_turn_started() -> void:
	turn_time_remaining = turn_duration
	turn_timer.start()


func _on_match_manager_turn_finished() -> void:
	_start_turn()


func _on_turn_timer_timeout() -> void:
	turn_time_remaining -= 1

	if turn_time_remaining <= 0:
		_end_turn()


func _on_busy_manager_busy_ended() -> void:
	_end_turn()


func _on_busy_manager_busy_started() -> void:
	turn_timer.stop()
