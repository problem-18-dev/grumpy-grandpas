extends PlayerState

@export_group("Properties")
@export var jump_force := -350.0
@export var jump_backwards_force := -400.0
@export var jump_backwards_velocity := 25.0
@export_group("Falling")
@export var fall_minimum_velocity := 700.0
@export var fall_damage := 15
@export var fall_damage_duration := 2.5

var _highest_falling_speed := 0.0
var _has_fallen := false


func enter(data := { }) -> void:
	player.unequip_aimable()

	if data.has("jump"):
		_jump()


func exit() -> void:
	_highest_falling_speed = 0.0
	_has_fallen = false


func _physics_update(delta: float) -> void:
	if _has_fallen:
		return

	_apply_gravity(delta)
	player.move_and_slide()
	_handle_falling()
	_handle_landing()


func _jump() -> void:
	player.velocity.y = jump_force


func _handle_falling() -> void:
	if player.velocity.y < 0:
		return

	_highest_falling_speed = maxf(_highest_falling_speed, player.velocity.y)


func _handle_landing() -> void:
	if not player.is_on_floor():
		return

	if _highest_falling_speed > fall_minimum_velocity:
		_fall_damage()
		return

	if not is_zero_approx(player.get_direction()):
		finished.emit(PlayerState.WALK)
		return

	finished.emit(PlayerState.IDLE)


func _fall_damage() -> void:
	_has_fallen = true

	EventSystem.busy.busy_started.emit(player)
	player.velocity = Vector2.ZERO
	player.register_damage(fall_damage)
	await get_tree().create_timer(fall_damage_duration).timeout
	EventSystem.busy.busy_finished.emit(player)
	finished.emit(PlayerState.INACTIVE)
