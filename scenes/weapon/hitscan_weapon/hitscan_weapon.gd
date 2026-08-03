class_name HitscanWeapon
extends Weapon

var _resource: HitscanWeaponResource

@onready var hitscan_ray_cast: RayCast2D = $HitscanRayCast


func _ready() -> void:
	super()
	_resource = weapon_resource as HitscanWeaponResource
	weapon_crosshair.position = Vector2(_resource.crosshair_distance, 0)
	hitscan_ray_cast.position = _resource.muzzle_offset
	hitscan_ray_cast.target_position = Vector2(_resource.weapon_range, 0)
	hitscan_ray_cast.force_update_transform()


func _unhandled_key_input(event: InputEvent) -> void:
	if not _is_enabled:
		return

	if event.is_action_pressed("shoot"):
		shoot()


func shoot() -> void:
	hitscan_ray_cast.force_raycast_update()

	_disable()

	if not hitscan_ray_cast.is_colliding():
		return

	var collider := hitscan_ray_cast.get_collider()

	if collider is HurtboxComponent:
		var collision_point := hitscan_ray_cast.get_collision_point()
		var distance_to_target := hitscan_ray_cast.global_position.distance_to(collision_point)
		var damage_ratio := distance_to_target / _resource.weapon_range
		var damage_falloff := _resource.damage_falloff_curve.sample(damage_ratio)
		var calculated_damage := roundi(_resource.damage * damage_falloff)
		collider.hit(calculated_damage)
		return

	# TODO: Only other collision can be the world
