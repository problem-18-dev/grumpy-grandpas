extends PlayerState

@export_group("Properties")
@export var knockback_weight := 200.0
@export var upward_force := 0.5
@export var inactive_speed := 10.0

var _finished := false


func enter(data := { }) -> void:
	_finished = false
	player.unequip_weapon()

	if not data.has("force") or not data.has("angle"):
		push_error("Entered knockback state without force or angle")
		finished.emit(PlayerState.INACTIVE)
		return

	var angle: float = data.get("angle")
	var force: float = data.get("force")
	var direction := Vector2.from_angle(angle)
	direction.y -= upward_force
	player.velocity += direction.normalized() * force


func _physics_update(delta: float) -> void:
	if _finished:
		return

	if not player.is_on_floor():
		_apply_gravity(delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, knockback_weight * delta)

	player.move_and_slide()

	if player.is_on_floor() and player.velocity.length() < inactive_speed:
		finished.emit(PlayerState.INACTIVE)
		_finished = true
