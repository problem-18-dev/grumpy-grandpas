class_name TutorialLevel
extends Node2D

signal projectile_exited

@onready var bounds_area: BoundsArea = $BoundsArea
@onready var enemy_spawn_marker: Marker2D = $EnemySpawnMarker
@onready var player_spawn_marker: Marker2D = $PlayerSpawnMarker
@onready var pickuppable_spawn_marker: Marker2D = $PickuppableSpawnMarker
@onready var keycap_spawn_marker: Marker2D = $KeycapSpawnMarker


## Player spawn must come last.
func get_spawn_points() -> Array[SpawnGenerator.SpawnPoint]:
	var player_spawn := SpawnGenerator.SpawnPoint.new(player_spawn_marker.global_position)
	var enemy_spawn := SpawnGenerator.SpawnPoint.new(enemy_spawn_marker.global_position)
	return [enemy_spawn, player_spawn]


func get_pickuppable_spawn() -> Vector2:
	return pickuppable_spawn_marker.global_position


func get_keycap_spawn() -> Vector2:
	return keycap_spawn_marker.global_position


func cleanup() -> void:
	bounds_area.cleanup()


func _on_bounds_area_projectile_exited() -> void:
	projectile_exited.emit()
