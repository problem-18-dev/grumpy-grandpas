@tool
class_name Projectile
extends CharacterBody2D

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
	global_position = start_position
	rotation = angle_in_rad
	velocity = Vector2.RIGHT.rotated(angle_in_rad) * force
	life_time_timer.start(resource.life_time)
	_is_fired = true


func _explode() -> void:
	_hit_targets()
	queue_free()


func _hit_targets() -> void:
	var space_state := get_world_2d().direct_space_state
	var shape_query := PhysicsShapeQueryParameters2D.new()
	shape_query.collision_mask = HURTBOX_COLLISION_MASK
	shape_query.collide_with_areas = true
	shape_query.collide_with_bodies = false
	shape_query.transform = Transform2D(0, global_position)

	var shape := CircleShape2D.new()
	shape.radius = resource.range_radius
	shape_query.shape = shape

	var collisions := space_state.intersect_shape(shape_query)

	if collisions.is_empty():
		return

	for collision in collisions:
		var collider: HurtboxComponent = collision.collider
		var distance_to_target := global_position.distance_to(collider.global_position)
		var calculated_damage := resource.damage.calculate_damage(
			distance_to_target,
			resource.range_radius,
		)
		collider.hit(calculated_damage)


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
