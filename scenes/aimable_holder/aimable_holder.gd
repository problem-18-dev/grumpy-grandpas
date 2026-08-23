class_name AimableHolder
extends Node2D

signal fired(ends_turn: bool, player_state: String, state_data: Dictionary)

const MINIMUM_ROTATION := -PI / 2
const MAXIMUM_ROTATION := PI / 2

@export_group("Properties")
@export var rotation_speed := 60.0

var _enabled := true
var _is_flipped := false
var _aim_angle := 0.0
var _equipped_aimable: Aimable

@onready var aimable_pivot: Node2D = $AimablePivot


func _physics_process(delta: float) -> void:
	if not _enabled:
		return

	register_aim_angle(delta)


func is_equipped() -> bool:
	return _equipped_aimable != null


func equip_aimable(aimable_resource: AimableResource, player_direction: float) -> void:
	if _equipped_aimable:
		remove_aimable()

	# Spawn aimable
	assert(aimable_resource.scene, "Aimble resource has no scene")
	var aimable: Aimable = load(aimable_resource.scene).instantiate()
	aimable.shot.connect(_on_aimable_shot)
	aimable.prepare(aimable_resource)
	aimable_pivot.add_child(aimable)
	_equipped_aimable = aimable

	# Flip aimable based on player's direction
	var should_flip := player_direction == Player.LEFT_DIRECTION
	_flip(should_flip)
	_equipped_aimable.flip(should_flip)

	_enabled = true
	set_physics_process(true)
	set_process_unhandled_key_input(true)


func remove_aimable() -> void:
	if not _equipped_aimable:
		return

	_equipped_aimable.queue_free()
	_equipped_aimable = null

	set_physics_process(false)
	set_process_unhandled_key_input(false)


func enable() -> void:
	_enabled = true


func disable() -> void:
	_enabled = false


func register_aim_angle(delta: float) -> void:
	var direction := Input.get_axis("up", "down")

	if is_zero_approx(direction):
		return

	_aim_angle += deg_to_rad(rotation_speed) * direction * delta
	_aim_angle = clampf(_aim_angle, MINIMUM_ROTATION, MAXIMUM_ROTATION)

	_rotate_aimable()


func _flip(should_flip: bool) -> void:
	_is_flipped = should_flip
	_rotate_aimable()


func _rotate_aimable() -> void:
	if _is_flipped:
		aimable_pivot.rotation = PI - _aim_angle
		return

	aimable_pivot.rotation = 0 + _aim_angle


func _on_aimable_shot(ends_turn: bool, player_state: String, state_data: Dictionary) -> void:
	if not ends_turn:
		disable()

	fired.emit(ends_turn, player_state, state_data)
