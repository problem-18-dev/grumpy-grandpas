extends PlayerState

@export_group("Properties")
@export var vertical_speed := -200.0
@export var horizontal_speed := 50.0
@export var decceleration_speed := 50.0
@export var weight := 0.15

var _is_flying := false


func enter(_data := { }) -> void:
	player.unequip_aimable()


func _key_input(event: InputEvent) -> void:
	if not player.is_on_floor() or not player.velocity.is_zero_approx():
		return

	if event.is_action_pressed("inventory"):
		player.toggle_inventory()


func _physics_update(delta: float) -> void:
	_handle_horizontal_movement()
	_handle_vertical_movement(delta)
	player.move_and_slide()


func _handle_horizontal_movement() -> void:
	if player.is_on_floor():
		player.velocity.x = lerpf(player.velocity.x, 0, weight)
		return

	var horizontal_direction := Input.get_axis("move_left", "move_right")
	var horizontal_movement := horizontal_speed * horizontal_direction
	player.velocity.x = lerpf(player.velocity.x, horizontal_movement, weight)


func _handle_vertical_movement(delta: float) -> void:
	if not player.is_on_floor():
		_apply_gravity(delta)
		player.velocity.y = minf(player.velocity.y, 50)

	_is_flying = Input.is_action_pressed("shoot")
	if not _is_flying:
		return

	player.velocity.y = lerpf(player.velocity.y, vertical_speed, weight)
