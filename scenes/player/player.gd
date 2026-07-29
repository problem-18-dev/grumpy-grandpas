extends CharacterBody2D

@export_group("Movement")
@export var movement_speed := 150.0


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	move_and_slide()


func _handle_movement() -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = movement_speed * direction


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return

	velocity.y += get_gravity().y * delta
