class_name WeaponHolder
extends Node2D

const MINIMUM_ROTATION := -PI / 2
const MAXIMUM_ROTATION := PI / 3
const HITSCAN_WEAPON = preload("uid://cc45g8xgg4lyo")

@export_group("Properties")
@export var rotation_speed := 60.0

var _is_flipped := false
var _aim_angle := 0.0
var _equipped_weapon: Weapon

@onready var weapon_pivot: Node2D = $WeaponPivot


func _physics_process(delta: float) -> void:
	_register_aim_angle(delta)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_shoot()


func _shoot() -> void:
	_equipped_weapon.shoot()


func is_equipped() -> bool:
	return _equipped_weapon != null


func equip_weapon(weapon_resource: WeaponResource, player_direction: float) -> void:
	if _equipped_weapon:
		remove_weapon()

	# Spawn weapon
	var weapon: Weapon

	if weapon_resource is HitscanWeaponResource:
		weapon = HITSCAN_WEAPON.instantiate()

	weapon.prepare(weapon_resource)
	weapon_pivot.add_child(weapon)
	_equipped_weapon = weapon

	var should_flip := player_direction == Player.LEFT_DIRECTION
	_flip(should_flip)
	_equipped_weapon.flip(should_flip)

	set_physics_process(true)
	set_process_unhandled_key_input(true)


## Removes weapon (from cache)
func remove_weapon() -> void:
	if not _equipped_weapon:
		return

	_equipped_weapon.queue_free()
	_equipped_weapon = null

	set_physics_process(false)
	set_process_unhandled_key_input(false)


func _flip(should_flip: bool) -> void:
	_is_flipped = should_flip
	_rotate_weapon()


func _register_aim_angle(delta: float) -> void:
	var direction := Input.get_axis("up", "down")

	if is_zero_approx(direction):
		return

	_aim_angle += deg_to_rad(rotation_speed) * direction * delta
	_aim_angle = clampf(_aim_angle, MINIMUM_ROTATION, MAXIMUM_ROTATION)

	_rotate_weapon()


func _rotate_weapon() -> void:
	if _is_flipped:
		weapon_pivot.rotation = PI - _aim_angle
		return

	weapon_pivot.rotation = 0 + _aim_angle
