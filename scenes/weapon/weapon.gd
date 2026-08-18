@abstract
class_name Aimable
extends Node2D

signal shot

@export var aimable_resource: AimableResource

var _is_enabled := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var crosshair: Crosshair = $Crosshair
@onready var muzzle_offset_marker: Marker2D = $MuzzleOffsetMarker


func _ready() -> void:
	if not aimable_resource:
		return

	sprite.texture = aimable_resource.texture
	muzzle_offset_marker.position = aimable_resource.muzzle_offset


func prepare(new_aimable_resource: AimableResource) -> void:
	aimable_resource = new_aimable_resource


func shoot() -> void:
	pass


func flip(should_flip: bool) -> void:
	sprite.flip_h = should_flip
	sprite.flip_v = should_flip
	crosshair.flip_v = should_flip


func enable() -> void:
	_is_enabled = true
	crosshair.enable()


func _disable() -> void:
	_is_enabled = false
	crosshair.disable()
