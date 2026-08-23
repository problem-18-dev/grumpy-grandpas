class_name GrappleHook
extends Aimable

const HOOK = preload("uid://ea3h4l4kvyor")

var _resource: GrappleHookResource

@onready var hitscan_ray_cast: RayCast2D = $HitscanRayCast


func _ready() -> void:
	super()

	_resource = aimable_resource
	crosshair.position = Vector2(_resource.crosshair_distance, 0)
	hitscan_ray_cast.position = _resource.muzzle_offset
	hitscan_ray_cast.target_position = Vector2.RIGHT * _resource.crosshair_distance


func _unhandled_key_input(event: InputEvent) -> void:
	if not _is_enabled:
		return

	if event.is_action_pressed("shoot"):
		shoot()
		get_viewport().set_input_as_handled()


func shoot() -> void:
	hitscan_ray_cast.force_raycast_update()

	if not hitscan_ray_cast.is_colliding():
		return

	var collider := hitscan_ray_cast.get_collider()

	# Can only be world
	if collider:
		var collision_point := hitscan_ray_cast.get_collision_point()
		var collision_normal := hitscan_ray_cast.get_collision_normal()
		var hook := _attach_hook(collision_point, collision_normal)
		_disable()
		shot.emit(false, PlayerState.GRAPPLE_HOOK, { "hook": hook })


func _attach_hook(point: Vector2, normal: Vector2) -> Hook:
	var hook: Hook = HOOK.instantiate()

	var objects := Utils.get_objects_container()
	objects.add_child(hook)

	var hook_rotation := normal.angle() + PI
	hook.spawn(point, hook_rotation)
	return hook
