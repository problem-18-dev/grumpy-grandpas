class_name Weapon
extends Node2D

@export var weapon_resource: WeaponResource

@onready var sprite: Sprite2D = $Sprite
@onready var projectile_start_marker: Marker2D = $ProjectileStartMarker


func _ready() -> void:
	assert(weapon_resource, "Weapon used without resource")

	sprite.texture = weapon_resource.texture
	projectile_start_marker.position = weapon_resource.start_position


func shoot() -> void:
	# Spawn projectile at projectile start marker
	# Projectile's entity decides what to do with itself
	Debug.log("%s shoots!" % weapon_resource.name)


func get_weapon_name() -> String:
	return weapon_resource.name
