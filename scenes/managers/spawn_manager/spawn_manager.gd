class_name SpawnManager
extends Node2D

const RAY_LENGTH := 1000

@export_group("Properties")
@export var spawn_path_follow: PathFollow2D
@export var spawn_attempts := 200

var _spawn_points: Array[Dictionary]


func generate_spawn_points() -> Array[Dictionary]:
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

		_spawn_points.append({ "spawn_position": collision.position, "spawn_normal": floor_normal })

	_spawn_points.shuffle()
	return _spawn_points
