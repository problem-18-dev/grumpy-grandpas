class_name MatchManager
extends Node2D

signal turn_finished
signal match_ended(winner: TeamResource)

@export var players_manager: PlayersManager


func initiate_match(spawn_points: Array[Dictionary]) -> void:
	players_manager.spawn_players(spawn_points)
	_start_turn()


func next_turn() -> void:
	players_manager.next_team()
	_start_turn()


func finish_turn() -> void:
	players_manager.deactivate_player()
	await players_manager.damage_players()
	await players_manager.kill_marked_players()
	turn_finished.emit()


func unlock_item(by: Player, type: PickuppableResource.Type) -> void:
	match type:
		PickuppableResource.Type.WEAPON:
			players_manager.unlock_weapon()
		PickuppableResource.Type.TOOL:
			players_manager.unlock_tool()
		PickuppableResource.Type.HEALTH:
			players_manager.heal_player(by)
		_:
			push_error("Unknown pickuppable type")


func _start_turn() -> void:
	if players_manager.teams.size() > 1:
		players_manager.activate_player()
		return

	var winner := players_manager.get_winner()
	match_ended.emit(winner)
