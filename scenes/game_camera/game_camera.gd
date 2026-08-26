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

var _targets: Dictionary[Node2D, Dictionary]
var _current_zoom := Zoom.NORMAL
var _zoom_tween: Tween

@onready var update_timer: Timer = $UpdateTimer
@onready var stall_timer: Timer = $StallTimer


func _init() -> void:
	if Engine.is_editor_hint():
		return

	EventSystem.camera.request_follow.connect(_on_request_follow)
	EventSystem.camera.revoke_follow.connect(_on_revoke_follow)


func _update_camera() -> void:
	# Nothing registered, keep following whatever we had until a new target arrives.
	if _targets.is_empty():
		return

	# If only one target available, follow no matter what.
	if _targets.size() == 1:
		if not is_instance_valid(_targets.keys()[0]):
			_update_zoom()
			return

		var new_target: Node2D = _targets.keys()[0]
		if new_target != follow_target:
			follow_target = new_target
			_log()

		_update_zoom()
		return

	var highest_priority_target: Node2D = follow_target if _targets.has(follow_target) else null

	# Change target to follow based on priority, doesn't change if no higher priority
	for next_target in _targets:
		if not highest_priority_target:
			highest_priority_target = next_target
			continue

		if _priority_of(next_target) > _priority_of(highest_priority_target):
			highest_priority_target = next_target

	if highest_priority_target != follow_target:
		follow_target = highest_priority_target
		_log()

	_update_zoom()


## Zoom always follows whoever we are currently following, so it cannot drift out of sync.
func _update_zoom() -> void:
	if not _targets.has(follow_target):
		return

	var new_zoom: Zoom = _targets[follow_target].get("zoom")
	_adjust_zoom(new_zoom)


func _adjust_zoom(new_zoom: Zoom) -> void:
	if new_zoom == _current_zoom:
		return

	_current_zoom = new_zoom

	if _zoom_tween and _zoom_tween.is_running():
		_zoom_tween.kill()

	_zoom_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE * ZOOM[new_zoom], ZOOM_TWEEN_DURATION)


func _priority_of(target: Node2D) -> Priority:
	return _targets[target].get("priority")


func _start_stall() -> void:
	stall_timer.start()
	update_timer.stop()


func _log() -> void:
	Debug.log("Moving camera to %s" % follow_target.name)


func _on_request_follow(
	target: Node2D,
	follow_priority: Priority,
	follow_zoom := Zoom.NORMAL,
) -> void:
	_targets[target] = { "priority": follow_priority, "zoom": follow_zoom }
	_update_camera()


func _on_revoke_follow(target: Node2D) -> void:
	_targets.erase(target)
	_update_camera()


func _on_update_timer_timeout() -> void:
	_update_camera()


func _on_stall_timer_timeout() -> void:
	update_timer.start()
