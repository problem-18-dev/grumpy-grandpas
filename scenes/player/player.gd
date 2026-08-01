class_name Player
extends CharacterBody2D

const LEFT_DIRECTION := -1
const RIGHT_DIRECTION := 1
const REVOLVER = preload("uid://dx1m0w6av86ds")
const SHOTGUN = preload("uid://bswdgh0ektx48")

var _last_direction := RIGHT_DIRECTION
var _weapon_to_equip := REVOLVER

@onready var weapon_holder: WeaponHolder = $WeaponHolder
@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(_delta: float) -> void:
	_flip_sprite()


func equip_weapon(weapon_resource: WeaponResource) -> void:
	weapon_holder.equip_weapon(weapon_resource, _last_direction)


func unequip_weapon() -> void:
	weapon_holder.remove_weapon()


func reequip_weapon() -> void:
	equip_weapon(_weapon_to_equip)


func get_direction() -> float:
	return Input.get_axis("move_left", "move_right")


func register_last_direction(new_last_direction: float) -> void:
	_last_direction = LEFT_DIRECTION if new_last_direction < 0 else RIGHT_DIRECTION


func _flip_sprite() -> void:
	if is_zero_approx(velocity.x):
		return

	sprite.flip_h = velocity.x < 0
