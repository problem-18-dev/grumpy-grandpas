@tool
class_name ProjectileWeapon
extends Aimable

const PROJECTILE := preload("uid://csa3ig7aroxsa")
const PRE_DEFINED_FORCE_TIME := 0.5

var _resource: ProjectileWeaponResource
var _is_charging := false
var _charge_tween: Tween
var _charge_time_left: float

@onready var muzzle_offset_marker: Marker2D = $MuzzleOffsetMarker
@onready var charge_sprite: Sprite2D = $ChargeSprite
@onready var charge_timer: Timer = $ChargeTimer


func _ready() -> void:
	super()

	_resource = aimable_resource as ProjectileWeaponResource
	assert(_resource.projectile_resource, "Using projectile weapon without projectile resource")

	muzzle_offset_marker.position = _resource.muzzle_offset
	charge_sprite.hide()
	charge_sprite.position = _resource.muzzle_offset


func _unhandled_key_input(event: InputEvent) -> void:
	if not _is_enabled or is_cpu:
		return

	var pressed := event.is_action_pressed("shoot")
	var released := event.is_action_released("shoot")
	process_input(pressed, released)

	if pressed or released:
		get_viewport().set_input_as_handled()


func shoot() -> void:
	charge_sprite.hide()

	# Prepare projectile
	var projectile: Projectile = PROJECTILE.instantiate()
	projectile.prepare(_resource.projectile_resource)

	# Add to level
	var entities := Utils.get_entities_container()
	entities.add_child(projectile)

	# Fire projectile
	var force := lerpf(
		_resource.min_force,
		_resource.max_force,
		inverse_lerp(_resource.charge_time, 0, _charge_time_left),
	)
	projectile.fire(muzzle_offset_marker.global_position, global_rotation, force)

	fired.emit()


func process_input(pressed: bool, released: bool, charge_force := 0.0) -> void:
	if not _is_enabled:
		return

	# Skip timer if charge force pre-defined
	if charge_force > 0.0:
		_kill_tween()
		var charge_scale := inverse_lerp(_resource.min_force, _resource.max_force, charge_force)
		charge_sprite.scale.x = charge_scale
		charge_sprite.show()
		_charge_time_left = _resource.charge_time * (1.0 - charge_scale)
		await get_tree().create_timer(PRE_DEFINED_FORCE_TIME).timeout
		shoot()
		charge_sprite.hide()
		return

	if pressed and not _is_charging:
		_start_charging()
	if released and _is_charging:
		_stop_charging()
		shoot()


func _start_charging() -> void:
	_tween_charge(1.0)
	charge_timer.start(_resource.charge_time)
	_is_charging = true


func _stop_charging() -> void:
	_kill_tween()
	_charge_time_left = charge_timer.time_left
	charge_timer.stop()
	_is_charging = false


func _kill_tween() -> void:
	if _charge_tween and _charge_tween.is_running():
		_charge_tween.kill()


func _tween_charge(charge_scale: float) -> void:
	_kill_tween()

	charge_sprite.scale.x = 0.0
	charge_sprite.show()
	_charge_tween = create_tween()
	_charge_tween.tween_property(charge_sprite, "scale:x", charge_scale, _resource.charge_time)


func _on_charge_timer_timeout() -> void:
	_stop_charging()
	shoot()
