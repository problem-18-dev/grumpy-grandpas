class_name SpawnGenerator
extends Node2D

const RAY_LENGTH := 1000

@export_group("Properties")
@export var spawn_path_follow: PathFollow2D
@export_range(16, 200) var spawn_attempts := 200

var _spawn_points: Array[SpawnPoint]


func generate_spawn_points() -> Array[SpawnPoint]:
	assert(spawn_path_follow, "No path follow provided.")

	var space_state := get_world_2d().direct_space_state

	for attempt in spawn_attempts:
		spawn_path_follow.progress_ratio = float(attempt) / spawn_attempts
		var query := PhysicsRayQueryParameters2D.create(
			spawn_path_follow.global_position,
			spawn_path_follow.global_position + (Vector2.DOWN * RAY_LENGTH),
			DestructiblePolygon2D.WORLD_COLLISION_LAYER,
		)

		var collision := space_state.intersect_ray(query)
		if not collision:
			continue

		var floor_normal: Vector2 = collision.normal
		var max_spawn_angle := cos(deg_to_rad(Player.FLOOR_MAX_ANGLE))
		if floor_normal.dot(Vector2.UP) < max_spawn_angle:
			continue

		var spawn_point := SpawnPoint.new(collision.position, floor_normal)
		_spawn_points.append(spawn_point)

	_spawn_points.shuffle()
	return _spawn_points


class SpawnPoint:
	var position: Vector2
	var normal: Vector2


	func _init(_position: Vector2, _normal := Vector2.ZERO) -> void:
		position = _position
		normal = _normal
