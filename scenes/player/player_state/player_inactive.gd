extends PlayerState


func enter(_data := { }) -> void:
	player.unequip_aimable()
	player.velocity = Vector2.ZERO


func _physics_update(delta: float) -> void:
	if not player.is_on_floor():
		_apply_gravity(delta)

	player.move_and_slide()
