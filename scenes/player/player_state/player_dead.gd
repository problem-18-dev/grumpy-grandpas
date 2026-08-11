extends PlayerState

const BED := preload("uid://dt41u72nlmr4c")
const PLAYER_EXPLOSION = preload("uid://d0al511wp4v17")

@export_group("Properties")
@export var death_timer := 3.0


func enter(_data := { }) -> void:
	EventSystem.camera.request_follow.emit(player, GameCamera.Priority.HIGH, GameCamera.Zoom.NEAR)
	_die()


func _die() -> void:
	Debug.log("%s has died" % player.name)
	player.name_label.text = "%s (dead)" % player.name

	await get_tree().create_timer(death_timer).timeout
	Utils.create_explosion(PLAYER_EXPLOSION, player.global_position)

	var bed: Bed = BED.instantiate()
	bed.global_position = player.global_position
	player.get_parent().add_child(bed)

	# Clean up
	EventSystem.camera.revoke_follow.emit(player)
	player.died.emit(player)
	player.queue_free()
