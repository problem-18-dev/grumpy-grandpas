class_name TutorialLevel
extends Node2D

signal projectile_exited

@onready var bounds_area: BoundsArea = $BoundsArea
@onready var enemy_spawn_marker: Marker2D = $EnemySpawnMarker
@onready var player_spawn_marker: Marker2D = $PlayerSpawnMarker
@onready var pickuppable_spawn_marker: Marker2D = $PickuppableSpawnMarker
@onready var top: CollisionShape2D = $BoundsArea/Top
@onready var right: CollisionShape2D = $BoundsArea/Right
@onready var bottom: CollisionShape2D = $BoundsArea/Bottom
@onready var left: CollisionShape2D = $BoundsArea/Left


func get_enemy_spawn() -> SpawnGenerator.SpawnPoint:
	var enemy_spawn := SpawnGenerator.SpawnPoint.new(enemy_spawn_marker.global_position)
	return enemy_spawn


func get_player_spawn() -> SpawnGenerator.SpawnPoint:
	var player_spawn := SpawnGenerator.SpawnPoint.new(player_spawn_marker.global_position)
	return player_spawn


func get_pickuppable_spawn() -> Vector2:
	return pickuppable_spawn_marker.global_position


func get_bounds() -> Array[int]:
	return [
		roundi(top.global_position.y),
		roundi(right.global_position.x),
		roundi(bottom.global_position.y),
		roundi(left.global_position.x),
	]


func cleanup() -> void:
	bounds_area.cleanup()


func _on_bounds_area_projectile_exited() -> void:
	projectile_exited.emit()
