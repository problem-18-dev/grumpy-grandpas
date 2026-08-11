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
var _zoom_tween: Tween

@onready var stall_timer: Timer = $StallTimer
@onready var update_timer: Timer = $UpdateTimer


func _init() -> void:
	if Engine.is_editor_hint():
		return

	EventSystem.camera.request_follow.connect(_on_request_follow)
	EventSystem.camera.revoke_follow.connect(_on_revoke_follow)


func _update_camera() -> void:
	# Do not change targets if stalling and already following more than one.
	if not stall_timer.is_stopped() and _targets.size() > 1:
		return

	# If only one target available, follow no matter what.
	if _targets.size() == 1:
		var new_target: Node2D = _targets.keys()[0]
		if new_target == follow_target:
			return

		follow_target = new_target
		var new_zoom: Zoom = _targets[new_target].get("zoom")
		_adjust_zoom(new_zoom)

		_log()
		stall_timer.start()
		return

	if not is_instance_valid(follow_target):
		return

	# Change target to follow based on priority, doesn't change if no higher priority
	for next_target in _targets.keys():
		var current := _targets[follow_target]
		var next := _targets[next_target]

		if next.get("priority") > current.get("priority"):
			follow_target = next_target
			var new_zoom = next.get("zoom")
			_adjust_zoom(new_zoom)

	_log()


func _adjust_zoom(new_zoom: Zoom) -> void:
	if _zoom_tween and _zoom_tween.is_running():
		_zoom_tween.kill()

	_zoom_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE * ZOOM[new_zoom], ZOOM_TWEEN_DURATION)


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
