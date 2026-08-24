extends Node2D

@onready var turn_manager: TurnManager = $TurnManager
@onready var spawn_manager: SpawnManager = $SpawnManager
@onready var busy_manager: BusyManager = $BusyManager
@onready var announcement_label: Label = $CanvasLayer/AnnouncementLabel


func _ready() -> void:
	var spawn_points := spawn_manager.generate_spawn_points()
	turn_manager.spawn_players(spawn_points)


func _on_busy_manager_busy_ended() -> void:
	turn_manager.next_turn()


func _on_turn_manager_match_ended(winner: TeamResource) -> void:
	if winner:
		announcement_label.text = "%s has won the game!" % winner.name
		return

	announcement_label.text = "It's a tie!"


func _on_turn_manager_turn_ended(_player: Player) -> void:
	busy_manager.reset()
