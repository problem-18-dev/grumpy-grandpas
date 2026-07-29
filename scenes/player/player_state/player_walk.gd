extends PlayerState

@export_group("Properties")
@export var movement_speed := 100.0


func _physics_update(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	player.move_and_slide()
	_check_floor()


func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit(PlayerState.AIR, { "jump": true })


func _handle_movement() -> void:
	var direction := Input.get_axis("move_left", "move_right")

	if is_zero_approx(direction):
		finished.emit(PlayerState.IDLE)
		return

	player.velocity.x = movement_speed * direction
