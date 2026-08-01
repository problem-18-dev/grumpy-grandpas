class_name HitscanWeapon
extends Weapon

@export var resource: HitscanWeaponResource

@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle_offset_marker: Marker2D = $MuzzleOffsetMarker
@onready var crosshair_sprite: Sprite2D = $CrosshairSprite
@onready var hitscan_ray_cast: RayCast2D = $HitscanRayCast


func _ready() -> void:
	if not resource:
		return

	sprite.texture = resource.texture
	hitscan_ray_cast.target_position.x = resource.max_range
	muzzle_offset_marker.position = resource.muzzle_offset
	hitscan_ray_cast.position = muzzle_offset_marker.position
	hitscan_ray_cast.force_update_transform()

	crosshair_sprite.hide()
	hitscan_ray_cast.enabled = false


func _physics_process(_delta: float) -> void:
	_render_crosshair()


func prepare(hitscan_weapon_resource: HitscanWeaponResource) -> void:
	resource = hitscan_weapon_resource


func shoot() -> void:
	if hitscan_ray_cast.is_colliding():
		var collider := hitscan_ray_cast.get_collider()
		if collider.is_in_group("players"):
			Debug.log("Player hit!")
		else:
			Debug.log("World hit!")


func flip(should_flip: bool) -> void:
	sprite.flip_h = should_flip


func _render_crosshair() -> void:
	if not hitscan_ray_cast.enabled:
		return

	if hitscan_ray_cast.is_colliding():
		crosshair_sprite.position = to_local(hitscan_ray_cast.get_collision_point())
		return

	crosshair_sprite.position = position + Vector2(resource.max_range, 0)
