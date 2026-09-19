class_name AimableHolder
extends Node2D

signal aimable_fired(life_time: float)
signal aimable_used(player_state: String, state_data: Dictionary)

enum HolderState {
	ENABLED,
	DISABLED,
}

const MINIMUM_ROTATION := -PI / 2
const MAXIMUM_ROTATION := PI / 2

@export_group("Properties")
@export var rotation_speed := 60.0
@export_group("CPU")
@export var aiming_time := 1.0

var is_cpu := false
var equipped_aimable: Aimable

var _is_flipped := false
var _aim_angle := 0.0
var _state := HolderState.DISABLED

@onready var aimable_pivot: Node2D = $AimablePivot


func _physics_process(delta: float) -> void:
	if _state == HolderState.DISABLED or is_cpu or InputGate.has_multiple(["up", "down"]):
		return

	register_aim_angle(delta)


func equip_aimable(aimable_resource: AimableResource, player_direction: float) -> void:
	if equipped_aimable:
		remove_aimable()

	# Spawn aimable
	assert(aimable_resource.scene, "Aimble resource has no scene")
	var aimable: Aimable = load(aimable_resource.scene).instantiate()
	aimable.is_cpu = is_cpu
	aimable.used.connect(_on_aimable_used)
	aimable.fired.connect(aimable_fired.emit)
	aimable.prepare(aimable_resource)
	aimable_pivot.add_child(aimable)
	equipped_aimable = aimable

	# Flip aimable based on player's direction
	var should_flip := player_direction == Player.LEFT_DIRECTION
	_flip(should_flip)
	equipped_aimable.flip(should_flip)

	_change_state(HolderState.ENABLED)


func remove_aimable() -> void:
	if not equipped_aimable:
		return

	equipped_aimable.queue_free()
	equipped_aimable = null

	_change_state(HolderState.DISABLED)


func register_aim_angle(delta: float) -> void:
	var direction := Input.get_axis("up", "down")

	if is_zero_approx(direction):
		return

	_aim_angle += deg_to_rad(rotation_speed) * direction * delta
	_aim_angle = clampf(_aim_angle, MINIMUM_ROTATION, MAXIMUM_ROTATION)

	_rotate_aimable()

#region CPU

## Only to be used by CPU teams. Immediately angles and shoots the current aimable.
func cpu_shoot(angle: float, force := 0.0) -> void:
	_aim_angle = angle
	_rotate_aimable()

	await get_tree().create_timer(aiming_time).timeout

	if equipped_aimable is ProjectileWeapon:
		assert(not is_zero_approx(force), "Manually shooting a projectile weapon without force.")
		(equipped_aimable as ProjectileWeapon).process_input(false, false, force)
		return

	equipped_aimable.shoot()
#endregion

func _change_state(new_state: HolderState) -> void:
	match new_state:
		HolderState.ENABLED:
			set_physics_process(true)
			set_process_unhandled_key_input(true)
		HolderState.DISABLED:
			set_physics_process(false)
			set_process_unhandled_key_input(false)
			if equipped_aimable:
				equipped_aimable.disable()

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
	_change_state(HolderState.DISABLED)
	aimable_used.emit(player_state, state_data)
