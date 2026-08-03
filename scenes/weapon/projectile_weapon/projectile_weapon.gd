@tool
class_name ProjectileWeapon
extends Weapon

const PROJECTILE = preload("uid://csa3ig7aroxsa")

@export var resource: ProjectileWeaponResource

var _is_charging := false
var _charge_tween: Tween
var _charge_time_left: float

@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle_offset_marker: Marker2D = $MuzzleOffsetMarker
@onready var weapon_crosshair: WeaponCrosshair = $WeaponCrosshair
@onready var charge_sprite: Sprite2D = $ChargeSprite
@onready var charge_timer: Timer = $ChargeTimer


func _ready() -> void:
	if not resource:
		return

	sprite.texture = resource.texture
	muzzle_offset_marker.position = resource.muzzle_offset
	charge_sprite.hide()
	charge_sprite.position = resource.muzzle_offset


func _unhandled_key_input(event: InputEvent) -> void:
	if not _is_enabled:
		return

	if event.is_action_pressed("shoot") and not _is_charging:
		_start_charging()

	if event.is_action_released("shoot") and _is_charging:
		_stop_charging()
		shoot()


func prepare(hitscan_weapon_resource: ProjectileWeaponResource) -> void:
	resource = hitscan_weapon_resource


func shoot() -> void:
	assert(resource.projectile_resource, "Attempting to shoot projectile without projectile scene")

	# Enable later, can stay enabled for testing
	#_disable()
	charge_sprite.hide()

	# Prepare projectile
	var projectile: Projectile = PROJECTILE.instantiate()
	projectile.prepare(resource.projectile_resource)

	# Fire projectile
	var force := _calculate_force()
	projectile.fire(muzzle_offset_marker.global_position, global_rotation, force)

	# Add to level
	var projectiles_container := get_tree().get_first_node_in_group("projectiles")
	projectiles_container.add_child(projectile)


func flip(should_flip: bool) -> void:
	sprite.flip_h = should_flip
	sprite.flip_v = should_flip
	weapon_crosshair.flip_v = should_flip


func _start_charging() -> void:
	charge_sprite.scale.x = 0.0
	charge_sprite.show()

	_charge_tween = create_tween()
	_charge_tween.tween_property(charge_sprite, "scale:x", 1.0, resource.charge_time)
	charge_timer.start(resource.charge_time)

	_is_charging = true


func _stop_charging() -> void:
	if _charge_tween and _charge_tween.is_running():
		_charge_tween.kill()

	_charge_time_left = charge_timer.time_left
	charge_timer.stop()

	_is_charging = false


func _calculate_force() -> float:
	return lerpf(
		resource.min_force,
		resource.max_force,
		inverse_lerp(resource.charge_time, 0, _charge_time_left),
	)


func _enable() -> void:
	_is_enabled = true
	weapon_crosshair.setup(resource.crosshair_distance)
	weapon_crosshair.enable()
	weapon_ready.emit()


func _disable() -> void:
	_is_enabled = false
	weapon_crosshair.disable()
	weapon_shot.emit()


func _on_charge_timer_timeout() -> void:
	_stop_charging()
	shoot()
