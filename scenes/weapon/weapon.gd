@abstract
class_name Weapon
extends Node2D

signal weapon_ready
signal weapon_shot

@export var weapon_resource: WeaponResource

var _is_enabled := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var weapon_crosshair: WeaponCrosshair = $WeaponCrosshair
@onready var muzzle_offset_marker: Marker2D = $MuzzleOffsetMarker


func _ready() -> void:
	if not weapon_resource:
		return

	sprite.texture = weapon_resource.texture
	muzzle_offset_marker.position = weapon_resource.muzzle_offset


func prepare(new_weapon_resource: WeaponResource) -> void:
	weapon_resource = new_weapon_resource


func shoot() -> void:
	pass


func flip(should_flip: bool) -> void:
	sprite.flip_h = should_flip
	sprite.flip_v = should_flip
	weapon_crosshair.flip_v = should_flip


func enable() -> void:
	_is_enabled = true
	weapon_crosshair.enable()
	weapon_ready.emit()


func _disable() -> void:
	_is_enabled = false
	weapon_crosshair.disable()
	weapon_shot.emit()
