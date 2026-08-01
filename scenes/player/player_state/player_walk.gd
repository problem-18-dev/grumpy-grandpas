extends PlayerState

@export_group("Properties")
@export var movement_speed := 100.0


func enter(_data := { }) -> void:
	player.unequip_weapon()


func _physics_update(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	player.move_and_slide()
	_check_floor()


func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		finished.emit(PlayerState.AIR, { "jump": true })


func _handle_movement() -> void:
	var direction := player.get_direction()

	if is_zero_approx(direction):
		finished.emit(PlayerState.IDLE)
		return

	player.register_last_direction(direction)
	player.velocity.x = movement_speed * direction
