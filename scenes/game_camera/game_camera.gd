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
const SETTLE_MIN_TIME := 0.25
const SETTLE_STILL_FRAMES := 5
const SETTLE_TOLERANCE := 0.5

@export var manual_target_speed := 200.0

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


## Resolves once the camera stopped moving and zooming, or after the timeout.
func wait_until_settled(timeout := 2.0) -> void:
	var camera := get_viewport().get_camera_2d()
	var last_center := camera.get_screen_center_position()
	var elapsed := 0.0
	var still_frames := 0

	while elapsed < timeout:
		await get_tree().process_frame
		elapsed += get_process_delta_time()

		var center := camera.get_screen_center_position()
		var is_still := center.distance_to(last_center) <= SETTLE_TOLERANCE
		still_frames = still_frames + 1 if is_still else 0
		last_center = center

		var is_zooming := _zoom_tween != null and _zoom_tween.is_running()
		if elapsed >= SETTLE_MIN_TIME and still_frames >= SETTLE_STILL_FRAMES and not is_zooming:
			return


func _update_camera() -> void:
	if _manual_override:
		return

	# Nothing registered, keep following whatever we had until a new target arrives.
	if targets.is_empty():
		return

	# If only one target available, follow no matter what.
	if targets.size() == 1:
		if not is_instance_valid(targets.keys()[0]):
			_update_zoom()
			return

		var new_target: Node2D = targets.keys()[0]
		if new_target != follow_target:
			_change_target(new_target)

		_update_zoom()
		return

	var highest_priority_target: Node2D = (
		follow_target
		if (follow_target and targets.has(follow_target))
		else null
	)

	# Change target to follow based on priority, doesn't change if no higher priority
	for next_target in targets:
		if not is_instance_valid(next_target):
			continue

		if not highest_priority_target:
			highest_priority_target = next_target
			continue

		if _priority_of(next_target) > _priority_of(highest_priority_target):
			highest_priority_target = next_target

	if highest_priority_target != follow_target:
		_change_target(highest_priority_target)

	_update_zoom()


## Zoom always follows whoever we are currently following, so it cannot drift out of sync.
func _update_zoom() -> void:
	if not follow_target:
		_adjust_zoom(Zoom.NORMAL)
		return

	if not targets.has(follow_target):
		return

	var new_zoom: Zoom = targets[follow_target].get("zoom")
	_adjust_zoom(new_zoom)


func _adjust_zoom(new_zoom: Zoom) -> void:
	if new_zoom == _current_zoom:
		return

	_current_zoom = new_zoom

	if _zoom_tween and _zoom_tween.is_running():
		_zoom_tween.kill()

	_zoom_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE * ZOOM[new_zoom], ZOOM_TWEEN_DURATION)


func _change_target(new_target: Node2D) -> void:
	follow_target = new_target
	_start_stall()


func _priority_of(target: Node2D) -> Priority:
	return targets[target].get("priority")


func _start_stall() -> void:
	stall_timer.start()
	update_timer.stop()


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
	_adjust_zoom(Zoom.FAR)
	manual_target.global_position = manual_position
	follow_target = manual_target


func _on_revoke_manual() -> void:
	_manual_override = false
	_update_camera()


func _on_update_timer_timeout() -> void:
	_update_camera()


func _on_stall_timer_timeout() -> void:
	update_timer.start()
