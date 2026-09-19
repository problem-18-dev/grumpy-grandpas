class_name PickuppableManager
extends Node2D

signal picked_up(by: Player, type: PickuppableResource.Type)

const PICKUPPABLE = preload("uid://3i8oy7ede3he")
const RAY_LENGTH := 1000
const HURTBOX_COLLISION_MASK := 4

@export_group("Properties")
@export var spawn_chance := 0.15
@export var spawn_vertical_offset := 64.0
@export_group("Guards")
@export var should_check_for_players := true
@export var player_guard_range := 32.0
@export_group("Resources")
@export var spawn_resources: Array[PickuppableResource]

var spawn_follow: PathFollow2D

var _space_state: PhysicsDirectSpaceState2D


func setup(new_spawn_follow: PathFollow2D) -> void:
	spawn_follow = new_spawn_follow


func spawn(pickuppable_resource: PickuppableResource, spawn_position: Vector2) -> void:
	print("Spawning %s" % pickuppable_resource.name)

	var pickuppable: Pickuppable = PICKUPPABLE.instantiate()
	pickuppable.picked_up.connect(picked_up.emit)
	pickuppable.setup(pickuppable_resource)
	add_child(pickuppable)
	pickuppable.spawn(spawn_position)

	await pickuppable.spawned


func attempt_spawn() -> void:
	assert(spawn_follow, "Attempting spawn without path follow")

	if spawn_resources.is_empty():
		push_warning("No spawn resources assigned, skipping.")
		return

	if not _should_spawn():
		return

	_space_state = get_world_2d().direct_space_state

	var world_position := _get_world_position()
	if not world_position:
		return

	var players_nearby := _check_players_nearby(world_position)
	if players_nearby:
		return

	var pickuppable_to_spawn: PickuppableResource = spawn_resources.pick_random()
	var offset_position := _get_offset_position(world_position, pickuppable_to_spawn)
	if not offset_position:
		return

	await spawn(pickuppable_to_spawn, offset_position)


func _should_spawn() -> bool:
	return randf() <= spawn_chance


func _get_world_position() -> Vector2:
	spawn_follow.progress_ratio = randf()

	var world_query := PhysicsRayQueryParameters2D.create(
		spawn_follow.global_position,
		spawn_follow.global_position + (Vector2.DOWN * RAY_LENGTH),
		DestructiblePolygon2D.WORLD_COLLISION_LAYER,
	)

	var world_collision := _space_state.intersect_ray(world_query)
	return world_collision.position if world_collision else Vector2.ZERO


func _get_offset_position(
	world_position: Vector2,
	pickuppable_resource: PickuppableResource,
) -> Vector2:
	var offset_position: Vector2 = world_position + (Vector2.UP * spawn_vertical_offset)
	var shape_query := Utils.create_shape_query(
		DestructiblePolygon2D.WORLD_COLLISION_LAYER,
		offset_position,
		false,
		true,
	)
	var shape := CircleShape2D.new()
	shape.radius = pickuppable_resource.pickup_radius
	shape_query.shape = shape

	var collisions := _space_state.intersect_shape(shape_query)
	return Vector2.ZERO if collisions.size() > 0 else offset_position


func _check_players_nearby(check_position: Vector2) -> bool:
	if not should_check_for_players:
		return false

	var shape_query := Utils.create_shape_query(HURTBOX_COLLISION_MASK, check_position)
	var shape := CircleShape2D.new()
	shape.radius = player_guard_range
	shape_query.shape = shape
	var collisions := _space_state.intersect_shape(shape_query)
	return collisions.size() > 0
