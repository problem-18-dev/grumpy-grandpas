class_name AimableHolder
extends Node2D

signal aimable_fired
signal aimable_used(player_state: String, state_data: Dictionary)

enum HolderState {
	ENABLED,
	DISABLED,
	USED,
}

const MINIMUM_ROTATION := -PI / 2
const MAXIMUM_ROTATION := PI / 2

@export_group("Properties")
@export var rotation_speed := 60.0

var _is_flipped := false
var _aim_angle := 0.0
var _equipped_aimable: Aimable
var _state := HolderState.DISABLED

@onready var aimable_pivot: Node2D = $AimablePivot


func _physics_process(delta: float) -> void:
	if _state == HolderState.DISABLED:
		return

	register_aim_angle(delta)


func equip_aimable(aimable_resource: AimableResource, player_direction: float) -> void:
	if _equipped_aimable:
		remove_aimable()

	# Spawn aimable
	assert(aimable_resource.scene, "Aimble resource has no scene")
	var aimable: Aimable = load(aimable_resource.scene).instantiate()
	aimable.used.connect(_on_aimable_used)
	aimable.fired.connect(aimable_fired.emit)
	aimable.prepare(aimable_resource)
	aimable_pivot.add_child(aimable)
	_equipped_aimable = aimable

	# Flip aimable based on player's direction
	var should_flip := player_direction == Player.LEFT_DIRECTION
	_flip(should_flip)
	_equipped_aimable.flip(should_flip)

	_change_state(HolderState.ENABLED)


func remove_aimable() -> void:
	if not _equipped_aimable:
		return

	_equipped_aimable.queue_free()
	_equipped_aimable = null

	_change_state(HolderState.DISABLED)


func register_aim_angle(delta: float) -> void:
	var direction := Input.get_axis("up", "down")

	if is_zero_approx(direction):
		return

	_aim_angle += deg_to_rad(rotation_speed) * direction * delta
	_aim_angle = clampf(_aim_angle, MINIMUM_ROTATION, MAXIMUM_ROTATION)

	_rotate_aimable()


func _change_state(new_state: HolderState) -> void:
	match new_state:
		HolderState.ENABLED:
			set_physics_process(true)
			set_process_unhandled_key_input(true)
		HolderState.DISABLED:
			set_physics_process(false)
			set_process_unhandled_key_input(false)
		HolderState.USED:
			set_physics_process(false)
			set_process_unhandled_key_input(false)
			_equipped_aimable.disable()

	_state = new_state


func _flip(should_flip: bool) -> void:
	_is_flipped = should_flip
	_rotate_aimable()


func _rotate_aimable() -> void:
	if _is_flipped:
		aimable_pivot.rotation = PI - _aim_angle
		return

	aimable_pivot.rotation = 0 + _aim_angle


func _on_aimable_used(player_state: String, state_data: Dictionary) -> void:
	_change_state(HolderState.USED)
	aimable_used.emit(player_state, state_data)
