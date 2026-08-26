class_name PickuppableManager
extends Node2D

signal picked_up(by: Player, type: PickuppableResource.Type)

const PICKUPPABLE = preload("uid://3i8oy7ede3he")
const RAY_LENGTH := 1000
const HURTBOX_COLLISION_MASK := 4

@export_group("Properties")
@export var spawn_chance := 0.15
@export var spawn_follow: PathFollow2D
@export_group("Guards")
@export var should_check_for_players := true
@export var player_guard_range := 32.0
@export_group("Resources")
@export var spawn_resources: Array[PickuppableResource]


func _ready() -> void:
	assert(spawn_follow, "No spawn follow provided.")


func attempt_spawn() -> void:
	if spawn_resources.is_empty():
		push_warning("No spawn resources assigned, skipping.")
		return

	if not _should_spawn():
		return

	var spawn_position := _get_spawn_position()
	if not spawn_position:
		return

	var players_nearby := _check_players_nearby(spawn_position)
	if players_nearby:
		return

	var pickuppable_resource: PickuppableResource = spawn_resources.pick_random()
	Debug.log("Spawning %s" % pickuppable_resource.name)
	var pickuppable: Pickuppable = PICKUPPABLE.instantiate()
	pickuppable.picked_up.connect(picked_up.emit)

	pickuppable.setup(pickuppable_resource)
	add_child(pickuppable)
	pickuppable.spawn(spawn_position)
	await pickuppable.spawned


func _should_spawn() -> bool:
	return randf() <= spawn_chance


func _get_spawn_position() -> Vector2:
	spawn_follow.progress_ratio = randf()

	var world_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		spawn_follow.global_position,
		spawn_follow.global_position + (Vector2.DOWN * RAY_LENGTH),
		DestructiblePolygon2D.WORLD_COLLISION_LAYER,
	)

	var collision := world_state.intersect_ray(query)
	return collision.position if collision else null


func _check_players_nearby(check_position: Vector2) -> bool:
	if not should_check_for_players:
		return false

	var shape_query := Utils.create_shape_query(HURTBOX_COLLISION_MASK, check_position)
	var shape := CircleShape2D.new()
	shape.radius = player_guard_range
	shape_query.shape = shape

	var space_state := get_world_2d().direct_space_state
	var collisions := space_state.intersect_shape(shape_query)
	return collisions.size() > 0
