class_name Player
extends CharacterBody2D

const REVOLVER_WEAPON = preload("uid://27pu8wn0fth2")
const SHOTGUN_WEAPON = preload("uid://dc3cdaiwvnxvi")

var _weapon_to_equip := REVOLVER_WEAPON

@onready var weapon_holder: WeaponHolder = $WeaponHolder
@onready var sprite: Sprite2D = $Sprite2D


func _physics_process(_delta: float) -> void:
	_flip()


func equip_weapon(weapon_resource: WeaponResource) -> void:
	weapon_holder.equip_weapon(weapon_resource)


func unequip_weapon() -> void:
	weapon_holder.remove_weapon()


func reequip_weapon() -> void:
	equip_weapon(_weapon_to_equip)


func _flip() -> void:
	sprite.flip_h = velocity.x < 0


func _on_revolver_button_pressed() -> void:
	_weapon_to_equip = REVOLVER_WEAPON

	if weapon_holder.is_equipped():
		equip_weapon(_weapon_to_equip)


func _on_shotgun_button_pressed() -> void:
	_weapon_to_equip = SHOTGUN_WEAPON

	if weapon_holder.is_equipped():
		equip_weapon(_weapon_to_equip)
