@tool
class_name Projectile
extends CharacterBody2D

const EXPLOSION = preload("uid://dchrvlerl7kne")
const HURTBOX_COLLISION_MASK := 4

@export var resource: ProjectileResource

var _is_fired := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var life_time_timer: Timer = $LifeTimeTimer


func _ready() -> void:
	if not resource:
		return

	sprite.texture = resource.texture
	collision_shape.shape = resource.collision_shape


func _physics_process(delta: float) -> void:
	if not resource or not _is_fired:
		return

	_handle_gravity(delta)
	_handle_rotation()
	var collision := move_and_collide(velocity * delta)
	_handle_collision(collision)


func prepare(projectile_resource: ProjectileResource) -> void:
	resource = projectile_resource


func fire(start_position: Vector2, angle_in_rad: float, force: float) -> void:
	EventSystem.business.busy_started.emit(self)
	EventSystem.camera.request_follow.emit(self, GameCamera.Priority.MID)

	global_position = start_position
	rotation = angle_in_rad
	velocity = Vector2.RIGHT.rotated(angle_in_rad) * force
	life_time_timer.start(resource.life_time)
	_is_fired = true


func _explode() -> void:
	_damage_targets()
	_knockback_targets()
	EventSystem.business.busy_finished.emit(self)
	EventSystem.camera.revoke_follow.emit(self)
	_spawn_explosion()
	queue_free()


func _damage_targets() -> void:
	var shape_query := Utils.create_shape_query(HURTBOX_COLLISION_MASK, global_position)
	var shape := CircleShape2D.new()
	shape.radius = resource.damage.max_range
	shape_query.shape = shape

	var space_state := get_world_2d().direct_space_state
	var collisions := space_state.intersect_shape(shape_query)

	if collisions.is_empty():
		return

	for collision in collisions:
		var collider: HurtboxComponent = collision.collider
		var distance_to_target := global_position.distance_to(collider.global_position)

		var damage := resource.damage.calculate(distance_to_target)
		collider.hit(damage)


func _knockback_targets() -> void:
	var shape_query := Utils.create_shape_query(HURTBOX_COLLISION_MASK, global_position)
	var shape := CircleShape2D.new()
	shape.radius = resource.knockback.max_range
	shape_query.shape = shape

	var space_state := get_world_2d().direct_space_state
	var collisions := space_state.intersect_shape(shape_query)

	for collision in collisions:
		var collider: HurtboxComponent = collision.collider
		var distance_to_target := global_position.distance_to(collider.global_position)

		var knockback := resource.knockback.calculate(distance_to_target)
		collider.knockback(knockback, global_position.angle_to_point(collider.global_position))


func _spawn_explosion() -> void:
	var explosion: Explosion = EXPLOSION.instantiate()
	var explosions := get_tree().get_first_node_in_group("explosions")
	explosions.add_child(explosion)
	explosion.global_position = global_position
	explosion.carve_terrain(resource.carve_radius)


func _carve_terrain() -> void:
	var terrain: DestructiblePolygon2D = get_tree().get_first_node_in_group("terrain")
	if not terrain:
		return

	var carve_polygon := DestructiblePolygon2D.build_circle_polygon(resource.carve_radius)
	terrain.destruct(carve_polygon, global_position)


func _handle_gravity(delta: float) -> void:
	velocity += get_gravity() * delta


func _handle_collision(collision: KinematicCollision2D) -> void:
	if not collision:
		return

	if resource.bounce_enabled:
		velocity = velocity.bounce(collision.get_normal())
		velocity /= resource.bounce_velocity_divider
		return

	_explode()


func _handle_rotation() -> void:
	rotation = velocity.angle()


func _on_life_time_timer_timeout() -> void:
	_explode()
