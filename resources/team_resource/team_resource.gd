class_name TeamResource
extends Resource

@export_group("Properties")
@export var name := "Team One"
@export var color := Color(1.0, 0.494, 0.427, 1.0)
@export_group("Players")
@export var players: Array[PlayerResource]


func get_players() -> Array[PlayerResource]:
	return players
