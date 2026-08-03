@tool
class_name Projectile
extends CharacterBody2D

@export var resource: ProjectileResource

var _is_fired := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox_shape: CollisionShape2D = $HitboxComponent/HitboxShape


func _ready() -> void:
	if not resource:
		return

	sprite.texture = resource.texture
	collision_shape.shape = resource.collision_shape
	hitbox_shape.shape = resource.range_shape


func _physics_process(delta: float) -> void:
	if not resource or not _is_fired:
		return

	_handle_gravity(delta)
	var collision := move_and_collide(velocity * delta)
	_handle_collision(collision)
	_handle_rotation()


func prepare(projectile_resource: ProjectileResource) -> void:
	resource = projectile_resource


func fire(start_position: Vector2, angle_in_rad: float, force: float) -> void:
	global_position = start_position
	rotation = angle_in_rad
	velocity = Vector2.RIGHT.rotated(angle_in_rad) * force
	_is_fired = true


func _explode() -> void:
	Debug.log("%s exploded" % resource.name)
	hitbox.hit_targets(resource.damage, resource.damage_falloff_curve)
	queue_free()


func _handle_gravity(delta: float) -> void:
	velocity += get_gravity() * delta


func _handle_collision(collision: KinematicCollision2D) -> void:
	if not collision:
		return

	if resource.should_bounce:
		velocity = velocity.bounce(collision.get_normal())
		return

	_explode()


func _handle_rotation() -> void:
	sprite.rotation = velocity.angle()
	collision_shape.rotation = velocity.angle()
