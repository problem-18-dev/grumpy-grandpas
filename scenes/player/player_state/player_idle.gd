extends PlayerState


func enter(_data := { }) -> void:
	EventSystem.camera.request_follow.emit(player, GameCamera.Priority.HIGH)
	player.velocity = Vector2.ZERO
	player.reequip_aimable()


func _physics_update(_delta: float) -> void:
	_handle_movement()
	player.move_and_slide()
	_check_floor()


func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit(PlayerState.AIR, { "jump": true })

	if event.is_action_pressed("inventory"):
		player.toggle_inventory()


func _handle_movement() -> void:
	var direction := player.get_direction()

	if not is_zero_approx(direction):
		finished.emit(PlayerState.WALK)
