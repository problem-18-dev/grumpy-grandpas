class_name Bed
extends CharacterBody2D


func _ready() -> void:
	floor_max_angle = Player.FLOOR_MAX_ANGLE


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
