extends Node2D

@onready var spawn_generator: SpawnGenerator = $SpawnGenerator
@onready var turn_manager: TurnManager = $Managers/TurnManager
@onready var players_manager: PlayersManager = $Managers/PlayersManager
@onready var busy_manager: BusyManager = $Managers/BusyManager
@onready var pickuppable_manager: PickuppableManager = $Managers/PickuppableManager
@onready var time_label: Label = $CanvasLayer/TimeLabel


func _ready() -> void:
	_prepare()
	_start_match()


func _prepare() -> void:
	var spawn_points := spawn_generator.generate_spawn_points()
	players_manager.spawn_players(spawn_points)


func _start_match() -> void:
	players_manager.activate_player()
	turn_manager.start_turn()


func _announce_winner() -> void:
	var winner := players_manager.get_winner()

	if winner:
		players_manager.show_team(winner)
		time_label.text = "%s has won!" % winner.name
		return

	time_label.text = "No winners this time!"


func _continue() -> void:
	if players_manager.teams.size() <= 1:
		_announce_winner()
		return

	busy_manager.reset()
	await pickuppable_manager.attempt_spawn()
	players_manager.next_team()
	players_manager.activate_player()
	turn_manager.start_turn()


func _on_pickuppable_manager_picked_up(by: Player, type: PickuppableResource.Type) -> void:
	players_manager.unlock_item(by, type)


func _on_busy_manager_busy_started() -> void:
	Debug.log("Busy started")
	turn_manager.hold_turn()


func _on_busy_manager_busy_ended() -> void:
	Debug.log("Busy ended")
	turn_manager.finish_turn()


func _on_turn_manager_time_changed(time: int) -> void:
	time_label.text = str(time)


func _on_turn_manager_transition_finished() -> void:
	await players_manager.damage_players()
	await players_manager.kill_marked_players()
	_continue()


func _on_turn_manager_turn_ended() -> void:
	players_manager.deactivate_player()
