extends PlayerState

@export_group("Movement")
@export var movement_speed := 75.0
@export var angular_speed := 1.5
@export_group("Limits")
@export var hook_min_distance := 25.0
@export var hook_max_distance := 200.0

var _hook: Hook
var _radius := 0.0
var _angle := 0.0


func enter(data := { }) -> void:
	_hook = data.get("hook")
	assert(_hook, "Entering grapple hook state without a hook in state data.")

	var offset := player.global_position - _hook.global_position
	_radius = offset.length()
	_angle = offset.angle()


func exit() -> void:
	_kill_hook()


func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		_release()
		get_viewport().set_input_as_handled()


func _physics_update(delta: float) -> void:
	if not _hook:
		return

	var input := Input.get_vector("move_left", "move_right", "down", "up")
	var new_radius := clampf(
		_radius - input.y * movement_speed * delta,
		hook_min_distance,
		hook_max_distance,
	)
	var new_angle := _angle + input.x * angular_speed * delta
	var target := _hook.global_position + Vector2.RIGHT.rotated(new_angle) * new_radius

	var collision := player.move_and_collide(target - player.global_position)

	if collision:
		return

	_radius = new_radius
	_angle = new_angle


func _release() -> void:
	_kill_hook()

	if player.is_on_floor():
		finished.emit(PlayerState.IDLE)
		return

	finished.emit(PlayerState.AIR)


func _kill_hook() -> void:
	if not _hook:
		return

	_hook.queue_free()
	_hook = null
