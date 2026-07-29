extends PlayerState


func _physics_update(_delta: float) -> void:
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

	player.velocity.x = player.movement_speed * direction
