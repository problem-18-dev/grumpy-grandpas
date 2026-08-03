class_name HitscanWeapon
extends Weapon

@export var resource: HitscanWeaponResource

@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle_offset_marker: Marker2D = $MuzzleOffsetMarker
@onready var weapon_crosshair: WeaponCrosshair = $WeaponCrosshair


func _ready() -> void:
	if not resource:
		return

	sprite.texture = resource.texture
	muzzle_offset_marker.position = resource.muzzle_offset
	weapon_crosshair.setup(resource.crosshair_distance)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()


func prepare(hitscan_weapon_resource: HitscanWeaponResource) -> void:
	resource = hitscan_weapon_resource


func shoot() -> void:
	# Create a world space query starting from muzzle offset to max range
	pass


func flip(should_flip: bool) -> void:
	sprite.flip_h = should_flip
	sprite.flip_v = should_flip
	weapon_crosshair.flip_v = should_flip
