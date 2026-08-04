extends PlayerState

@export_group("Properties")
@export var knockback_drag := 0.15


func enter(data := { }) -> void:
	player.unequip_weapon()

	if not data.has("force") or not data.has("angle"):
		push_error("Entered knockback state without force or angle")
		finished.emit(PlayerState.INACTIVE)
		return

	var angle: float = data.get("angle")
	var force: float = data.get("force")
	player.velocity = Vector2.from_angle(angle) * force


func _physics_update(delta: float) -> void:
	_apply_gravity(delta)
	player.velocity.x -= knockback_drag
	player.move_and_slide()
