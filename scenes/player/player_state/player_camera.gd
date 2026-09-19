extends PlayerState


func enter(_data := { }) -> void:
	EventSystem.camera.request_manual.emit(player.global_position)
	player.unequip_item()


func _key_input(event: InputEvent) -> void:
	if not event.is_action_pressed("camera"):
		return

	EventSystem.camera.revoke_manual.emit()
	finished.emit(PlayerState.IDLE)
