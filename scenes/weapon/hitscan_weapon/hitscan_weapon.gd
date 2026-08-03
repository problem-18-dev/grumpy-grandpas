class_name HitscanWeapon
extends Weapon

@export var resource: HitscanWeaponResource

@onready var sprite: Sprite2D = $Sprite2D
@onready var muzzle_offset_marker: Marker2D = $MuzzleOffsetMarker
@onready var weapon_crosshair: WeaponCrosshair = $WeaponCrosshair
@onready var hitscan_ray_cast: RayCast2D = $HitscanRayCast


func _ready() -> void:
	if not resource:
		return

	sprite.texture = resource.texture
	muzzle_offset_marker.position = resource.muzzle_offset
	hitscan_ray_cast.target_position = Vector2(resource.weapon_range, 0)


func _unhandled_key_input(event: InputEvent) -> void:
	if not _is_enabled:
		return

	if event.is_action_pressed("shoot"):
		shoot()


func prepare(hitscan_weapon_resource: HitscanWeaponResource) -> void:
	resource = hitscan_weapon_resource


func shoot() -> void:
	hitscan_ray_cast.force_raycast_update()

	_disable()

	if not hitscan_ray_cast.is_colliding():
		return

	var collider := hitscan_ray_cast.get_collider()

	if collider is HurtboxComponent:
		var distance_to_target := global_position.distance_to(collider.global_position)
		var damage_ratio := distance_to_target / resource.weapon_range
		var damage_falloff := resource.damage_falloff_curve.sample(damage_ratio)
		var calculated_damage := roundi(resource.damage * damage_falloff)
		collider.hit(calculated_damage)
		return

	# TODO: Only other collision can be the world


func flip(should_flip: bool) -> void:
	sprite.flip_h = should_flip
	sprite.flip_v = should_flip
	weapon_crosshair.flip_v = should_flip


func _enable() -> void:
	_is_enabled = true
	weapon_crosshair.setup(resource.crosshair_distance)
	weapon_crosshair.enable()
	weapon_ready.emit()


func _disable() -> void:
	_is_enabled = false
	weapon_crosshair.disable()
	weapon_shot.emit()
