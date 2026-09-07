extends PlayerState

@export_group("Properties")
@export var drown_speed := 30.0

var _is_sinking := true

@onready var drown_timer: Timer = $DrownTimer


func enter(_data := { }) -> void:
	EventSystem.busy.busy_started.emit(player)
	player.unequip_aimable()
	player.velocity = Vector2.DOWN * drown_speed

	_check_sink_limit()

	player.drowned.emit(player)


func _physics_update(_delta: float) -> void:
	if not _is_sinking:
		player.velocity = Vector2.ZERO
		return

	player.move_and_slide()
	_handle_collision()


func _check_sink_limit() -> void:
	player.floor_ray_cast.enabled = true
	player.floor_ray_cast.force_raycast_update()

	if not player.floor_ray_cast.is_colliding():
		drown_timer.start()
		return


func _handle_collision() -> void:
	for i in player.get_slide_collision_count():
		var collision := player.get_slide_collision(i)
		var collider := collision.get_collider()

		if not collider.is_in_group("terrain"):
			continue

		player.marked_for_death.emit(player)
		_is_sinking = false


func _finish_drowning() -> void:
	EventSystem.busy.busy_finished.emit(player)


func _on_drown_timer_timeout() -> void:
	_finish_drowning()
