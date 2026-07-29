extends PlayerState


func enter(data := { }) -> void:
	if data.has("jump"):
		_jump()


func _physics_update(delta: float) -> void:
	_apply_gravity(delta)
	player.move_and_slide()
	_handle_landing()


func _jump() -> void:
	player.velocity.y = player.jump_force


func _handle_landing() -> void:
	if not player.is_on_floor():
		return

	finished.emit(PlayerState.WALK)
