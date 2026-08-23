@tool
class_name ProjectileWeapon
extends Aimable

const PROJECTILE = preload("uid://csa3ig7aroxsa")

var _is_charging := false
var _charge_tween: Tween
var _charge_time_left: float
var _resource: ProjectileWeaponResource

@onready var muzzle_offset_marker: Marker2D = $MuzzleOffsetMarker
@onready var charge_sprite: Sprite2D = $ChargeSprite
@onready var charge_timer: Timer = $ChargeTimer


func _ready() -> void:
	super()
	_resource = aimable_resource as ProjectileWeaponResource
	muzzle_offset_marker.position = _resource.muzzle_offset
	charge_sprite.hide()
	charge_sprite.position = _resource.muzzle_offset
	crosshair.position = Vector2(_resource.crosshair_distance, 0)


func _unhandled_key_input(event: InputEvent) -> void:
	if not _is_enabled:
		return

	if event.is_action_pressed("shoot") and not _is_charging:
		_start_charging()
		get_viewport().set_input_as_handled()

	if event.is_action_released("shoot") and _is_charging:
		_stop_charging()
		shoot()
		get_viewport().set_input_as_handled()


func shoot() -> void:
	assert(_resource.projectile_resource, "Attempting to shoot projectile without projectile scene")

	_disable()
	charge_sprite.hide()

	# Prepare projectile
	var projectile: Projectile = PROJECTILE.instantiate()
	projectile.prepare(_resource.projectile_resource)

	# Add to level
	var objects := Utils.get_objects_container()
	objects.add_child(projectile)

	# Fire projectile
	var force := _calculate_force()
	projectile.fire(muzzle_offset_marker.global_position, global_rotation, force)

	shot.emit(_resource.ends_turn, "", { })


func _start_charging() -> void:
	charge_sprite.scale.x = 0.0
	charge_sprite.show()

	_charge_tween = create_tween()
	_charge_tween.tween_property(charge_sprite, "scale:x", 1.0, _resource.charge_time)
	charge_timer.start(_resource.charge_time)

	_is_charging = true


func _stop_charging() -> void:
	if _charge_tween and _charge_tween.is_running():
		_charge_tween.kill()

	_charge_time_left = charge_timer.time_left
	charge_timer.stop()

	_is_charging = false


func _calculate_force() -> float:
	return lerpf(
		_resource.min_force,
		_resource.max_force,
		inverse_lerp(_resource.charge_time, 0, _charge_time_left),
	)


func _on_charge_timer_timeout() -> void:
	_stop_charging()
	shoot()
