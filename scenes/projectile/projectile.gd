@tool
class_name Projectile
extends CharacterBody2D

const EXPLOSION = preload("uid://dchrvlerl7kne")
const SPIN_VELOCITY_MAX := 15.0

@export var resource: ProjectileResource

var _is_fired := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var life_time_timer: Timer = $LifeTimeTimer
@onready var hitbox_collision_shape: CollisionShape2D = $HitboxComponent/CollisionShape2D


func _ready() -> void:
	if not resource:
		return

	sprite.texture = resource.texture
	collision_shape.shape = resource.collision_shape
	hitbox_collision_shape.shape = resource.collision_shape


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
	EventSystem.busy.busy_started.emit(self)
	EventSystem.camera.request_follow.emit(self, GameCamera.Priority.MID, GameCamera.Zoom.FAR)

	global_position = start_position
	rotation = angle_in_rad
	velocity = Vector2.RIGHT.rotated(angle_in_rad) * force
	life_time_timer.start(resource.life_time)
	_is_fired = true


func destroy() -> void:
	EventSystem.busy.busy_finished.emit(self)
	EventSystem.camera.revoke_follow.emit(self)
	queue_free()


func cancel() -> void:
	life_time_timer.stop()


func _explode() -> void:
	Utils.create_explosion(resource.explosion, global_position)
	destroy()


func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
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
	if not resource.spin_enabled:
		rotation = velocity.angle()
		return

	var spin_speed: float
	if velocity.length() < SPIN_VELOCITY_MAX:
		spin_speed = 0
	else:
		spin_speed = minf(resource.spin_speed, absf(velocity.x)) * signf(velocity.x)

	print(spin_speed, " ", velocity.length())

	rotation_degrees += spin_speed * get_physics_process_delta_time()


func _on_life_time_timer_timeout() -> void:
	_explode()


func _on_hitbox_component_hit() -> void:
	if resource.bounce_enabled:
		return

	_explode()
