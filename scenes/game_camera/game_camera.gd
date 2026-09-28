@tool
class_name GameCamera
extends PhantomCamera2D

enum Priority {
	LOW = 1,
	MID = 2,
	HIGH = 3,
}

enum Zoom {
	NEAR,
	NORMAL,
	FAR,
}

const ZOOM := { Zoom.NEAR: 1.2, Zoom.NORMAL: 1.0, Zoom.FAR: 0.9 }
const ZOOM_TWEEN_DURATION := 0.5

@export var manual_target_speed := 150.0

var targets: Dictionary[Node2D, Dictionary]

var _current_zoom := Zoom.NORMAL
var _zoom_tween: Tween
var _manual_override := false

@onready var update_timer: Timer = $UpdateTimer
@onready var stall_timer: Timer = $StallTimer
@onready var noise_emitter: PhantomCameraNoiseEmitter2D = $NoiseEmitter
@onready var manual_target: Node2D = $ManualTarget


func _init() -> void:
	if Engine.is_editor_hint():
		return

	EventSystem.camera.request_follow.connect(_on_request_follow)
	EventSystem.camera.revoke_follow.connect(_on_revoke_follow)
	EventSystem.camera.shake.connect(_on_shake)
	EventSystem.camera.request_manual.connect(_on_request_manual)
	EventSystem.camera.revoke_manual.connect(_on_revoke_manual)


func _physics_process(delta: float) -> void:
	if not _manual_override:
		return

	var direction := Input.get_vector("move_left", "move_right", "up", "down")
	manual_target.global_position += manual_target_speed * direction * delta
	manual_target.global_position.x = clampf(
		manual_target.global_position.x,
		limit_left + (get_viewport_rect().size.x / 2) * ZOOM[_current_zoom],
		limit_right - (get_viewport_rect().size.x / 2) * ZOOM[_current_zoom],
	)
	manual_target.global_position.y = clampf(
		manual_target.global_position.y,
		limit_top + (get_viewport_rect().size.y / 2) * ZOOM[_current_zoom],
		limit_bottom - (get_viewport_rect().size.y / 2) * ZOOM[_current_zoom],
	)


func _update_camera() -> void:
	if _manual_override:
		return

	for target: Variant in targets.keys():  # Variant, typed Node2D errors on freed instances
		if not is_instance_valid(target):
			targets.erase(target)

	# Nothing registered, keep following whatever we had until a new target arrives.
	if targets.is_empty():
		return

	# Follow every target sharing the highest priority, lower ones wait their turn.
	var highest_priority: Priority = targets \
			.values() \
			.map(
		func(t: Dictionary) -> Priority:
			return t.priority,
	) \
			.max()
	var new_targets: Array[Node2D] = []
	new_targets.assign(
		targets.keys().filter(
			func(t: Node2D) -> bool:
				return targets[t].priority == highest_priority,
		)
	)

	_adjust_zoom(Zoom.FAR if new_targets.size() > 1 else targets[new_targets[0]].zoom)

	if new_targets == follow_targets:
		return

	follow_targets = new_targets
	_start_stall()
	_log()


func _adjust_zoom(new_zoom: Zoom) -> void:
	if new_zoom == _current_zoom:
		return

	_current_zoom = new_zoom

	if _zoom_tween and _zoom_tween.is_running():
		_zoom_tween.kill()

	_zoom_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE * ZOOM[new_zoom], ZOOM_TWEEN_DURATION)


func _start_stall() -> void:
	stall_timer.start()
	update_timer.stop()


func _log() -> void:
	print(
		"Moving camera to %s"
		% follow_targets.map(
			func(t: Node2D) -> String:
				return t.name,
		)
	)


## Addon only drops exiting targets from its internal list, leaving the freed node in follow_targets.
func _follow_target_tree_exiting(target: Node) -> void:
	super(target)
	targets.erase(target)
	follow_targets = follow_targets.filter(func(t: Node2D) -> bool: return t != target)
	_update_camera()


func _on_request_follow(
	target: Node2D,
	follow_priority: Priority,
	follow_zoom := Zoom.NORMAL,
) -> void:
	targets[target] = { "priority": follow_priority, "zoom": follow_zoom }
	_update_camera()


func _on_revoke_follow(target: Node2D) -> void:
	targets.erase(target)
	_update_camera()


func _on_shake(new_noise: PhantomCameraNoise2D, duration: float) -> void:
	noise_emitter.noise = new_noise
	noise_emitter.duration = duration
	noise_emitter.decay_time = duration / 3
	noise_emitter.emit()


func _on_request_manual(manual_position: Vector2) -> void:
	_manual_override = true
	manual_target.global_position = manual_position
	follow_targets = [manual_target]


func _on_revoke_manual() -> void:
	_manual_override = false
	_update_camera()


func _on_update_timer_timeout() -> void:
	_update_camera()


func _on_stall_timer_timeout() -> void:
	update_timer.start()
