extends PlayerState

const GRAPPLE_HOOK_STATS = preload("uid://c3pppa4dayl")

@export_group("Speed")
@export var extension_speed := 50.0
@export var extension_weight := 0.1
@export var rotation_speed := 50.0
@export_group("Limits")
@export var hook_min_distance := 15.0

var _hook_position: Vector2

@onready var hook_max_distance := GRAPPLE_HOOK_STATS.crosshair_distance


func enter(data := { }) -> void:
	assert(data.size() > 0, "Entering grapple hook without data")

	_hook_position = data.get("hook_position")


func _physics_update(_delta: float) -> void:
	_handle_hook_movement()
	player.move_and_slide()


func _handle_hook_movement() -> void:
	var extension_movement := Input.get_axis("up", "down")
	var extension_direction := Vector2.RIGHT.direction_to(_hook_position)

	player.velocity = extension_direction * extension_speed * extension_movement
