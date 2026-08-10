extends PlayerState

const BED = preload("uid://dt41u72nlmr4c")

# TODO: Add explosion on death


func enter(_data := { }) -> void:
	EventSystem.camera.request_follow.emit(player, GameCamera.Priority.HIGH)
	_die()


func _die() -> void:
	Debug.log("%s has died" % player.name)
	player.name_label.text = "%s (dead)" % player.name

	# TODO: Improve timing and handling
	await get_tree().create_timer(3).timeout
	var bed: Bed = BED.instantiate()
	bed.global_position = player.global_position
	player.get_parent().add_child(bed)

	# Clean up
	EventSystem.camera.revoke_follow.emit(player)
	player.died.emit(player)
	player.queue_free()
