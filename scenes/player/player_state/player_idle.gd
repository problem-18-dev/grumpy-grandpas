extends PlayerState


func enter(_data := { }) -> void:
	player.velocity = Vector2.ZERO
	player.reequip_item()


func _physics_update(_delta: float) -> void:
	_handle_movement()
	player.move_and_slide()
	_check_floor()


func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit(PlayerState.AIR, { "jump": true })

	if event.is_action_pressed("inventory"):
		player.request_inventory()
		get_viewport().set_input_as_handled()


func _handle_movement() -> void:
	var direction := player.get_direction()

	if not is_zero_approx(direction):
		finished.emit(PlayerState.WALK)
