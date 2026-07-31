class_name WeaponHolder
extends Node2D

const MINIMUM_ROTATION := -PI / 2
const MAXIMUM_ROTATION := PI / 3
const WEAPON_SCENE = preload("uid://la7en6yr566g")

@export_group("Properties")
@export var rotation_speed := 60.0

var _equipped_weapon: Weapon

@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var label: Label = $Label


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("up"):
		weapon_pivot.rotation_degrees -= rotation_speed * delta

	if Input.is_action_pressed("down"):
		weapon_pivot.rotation_degrees += rotation_speed * delta

	weapon_pivot.rotation = clampf(weapon_pivot.rotation, MINIMUM_ROTATION, MAXIMUM_ROTATION)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_shoot()


func _shoot() -> void:
	_equipped_weapon.shoot()


func is_equipped() -> bool:
	return _equipped_weapon != null


## Instantiates given weapon and caches it
func equip_weapon(new_weapon: WeaponResource) -> void:
	if _equipped_weapon:
		remove_weapon()

	var weapon: Weapon = WEAPON_SCENE.instantiate()
	weapon.weapon_resource = new_weapon
	weapon_pivot.add_child(weapon)
	_equipped_weapon = weapon
	label.text = _equipped_weapon.get_weapon_name()

	set_physics_process(true)
	set_process_unhandled_key_input(true)


## Removes weapon (from cache)
func remove_weapon() -> void:
	if not _equipped_weapon:
		return

	_equipped_weapon.queue_free()
	_equipped_weapon = null
	label.text = ""

	set_physics_process(false)
	set_process_unhandled_key_input(false)
