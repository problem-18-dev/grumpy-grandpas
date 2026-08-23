extends PlayerState

@export_group("Properties")
@export var jump_force := -350.0
@export var jump_backwards_force := -400.0
@export var jump_backwards_velocity := 25.0


func enter(data := { }) -> void:
	player.unequip_aimable()

	if data.has("jump"):
		_jump()


func _physics_update(delta: float) -> void:
	_apply_gravity(delta)
	player.move_and_slide()
	_handle_landing()


func _jump() -> void:
	player.velocity.y = jump_force


func _handle_landing() -> void:
	if not player.is_on_floor():
		return

	if not is_zero_approx(player.get_direction()):
		finished.emit(PlayerState.WALK)
		return

	finished.emit(PlayerState.IDLE)
