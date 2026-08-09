extends Node2D

@onready var turn_manager: TurnManager = $TurnManager
@onready var spawn_manager: SpawnManager = $SpawnManager


func _ready() -> void:
	spawn_manager.spawn_players()


func _on_spawn_manager_players_ready() -> void:
	turn_manager.start()


func _on_spawn_manager_player_spawned(team: TeamResource, player: Player) -> void:
	turn_manager.assign_player(team, player)


func _on_business_manager_business_ended() -> void:
	turn_manager.end_turn()
