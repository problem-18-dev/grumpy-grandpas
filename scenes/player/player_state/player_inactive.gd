extends PlayerState


func enter(data := { }) -> void:
	player.unequip_weapon()


func _physics_update(delta: float) -> void:
	_apply_gravity(delta)
	player.move_and_slide()
