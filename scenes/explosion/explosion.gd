@tool
class_name Explosion
extends Node2D

const HURTBOX_COLLISION_MASK := 4

@export var explosion_resource: ExplosionResource

@onready var timer: Timer = $Timer


func prepare(resource: ExplosionResource) -> void:
	explosion_resource = resource


func explode(explode_position: Vector2) -> void:
	global_position = explode_position
	EventSystem.busy.busy_started.emit(self)
	EventSystem.camera.request_follow.emit(self, GameCamera.Priority.MID)
	timer.start()

	_damage_targets()
	_knockback_targets()
	_carve_terrain()


func _damage_targets() -> void:
	var shape_query := Utils.create_shape_query(HURTBOX_COLLISION_MASK, global_position)
	var shape := CircleShape2D.new()
	shape.radius = explosion_resource.damage.max_range
	shape_query.shape = shape

	var space_state := get_world_2d().direct_space_state
	var collisions := space_state.intersect_shape(shape_query)

	if collisions.is_empty():
		return

	for collision in collisions:
		var collider: HurtboxComponent = collision.collider
		var distance_to_target := global_position.distance_to(collider.global_position)

		var damage := explosion_resource.damage.calculate(distance_to_target)
		collider.hit(damage)


func _knockback_targets() -> void:
	var shape_query := Utils.create_shape_query(HURTBOX_COLLISION_MASK, global_position)
	var shape := CircleShape2D.new()
	shape.radius = explosion_resource.knockback.max_range
	shape_query.shape = shape

	var space_state := get_world_2d().direct_space_state
	var collisions := space_state.intersect_shape(shape_query)

	for collision in collisions:
		var collider: HurtboxComponent = collision.collider
		var distance_to_target := global_position.distance_to(collider.global_position)

		var knockback := explosion_resource.knockback.calculate(distance_to_target)
		collider.knockback(knockback, global_position.angle_to_point(collider.global_position))


func _carve_terrain() -> void:
	var terrain: DestructiblePolygon2D = get_tree().get_first_node_in_group("terrain")
	if not terrain:
		return

	var carve_polygon := DestructiblePolygon2D.build_circle_polygon(explosion_resource.carve_radius)
	terrain.destruct(carve_polygon, global_position)


func _on_timer_timeout() -> void:
	EventSystem.busy.busy_finished.emit(self)
	EventSystem.camera.revoke_follow.emit(self)
	queue_free()
