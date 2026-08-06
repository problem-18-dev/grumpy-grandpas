class_name PlayerManager
extends Node2D

const PLAYER := preload("uid://bmag23mf230r3")
const SPAWN_POINT_ATTEMPTS := 200
const RAY_LENGTH := 1000

@export var play_area_follow: PathFollow2D

var _spawn_points: Array[Vector2] = []


func _ready() -> void:
	generate_spawn_points()
	spawn_players()


func spawn_players() -> void:
	Debug.log("Randomizing spawn")

	# TODO: To be changed when turn and team system comes into play. Placeholder for now
	var players := 6
	for i in players:
		var player: Player = PLAYER.instantiate()
		add_child(player)
		player.global_position = _spawn_points.pop_back()

	# TODO: Player activation should be controller by this manager, but actual management will come later.
	var active_player: Player = get_children().pick_random()
	active_player.activate()


func generate_spawn_points() -> void:
	var space_state := get_world_2d().direct_space_state

	for attempt in SPAWN_POINT_ATTEMPTS:
		play_area_follow.progress_ratio = float(attempt) / SPAWN_POINT_ATTEMPTS
		var query := PhysicsRayQueryParameters2D.create(
			play_area_follow.global_position,
			play_area_follow.global_position + (Vector2.DOWN * RAY_LENGTH),
			DestructiblePolygon2D.WORLD_COLLISION_LAYER,
		)
		var collision := space_state.intersect_ray(query)

		if not collision:
			continue

		# TODO: Should be offset by dot product of the floor
		var spawn_point: Vector2 = collision.position
		spawn_point.y -= Player.COLLISION_SHAPE_HEIGHT / 2
		_spawn_points.append(spawn_point)

	_spawn_points.shuffle()
