@tool
class_name GameCamera
extends PhantomCamera2D

enum Priority {
	LOW = 1,
	MID = 2,
	HIGH = 3,
}

var _targets: Dictionary[Node2D, Priority]
var _current_target: Node2D

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
		if new_target == _current_target:
			return

		_current_target = new_target
		follow_target = _current_target
		_log()
		stall_timer.start()
		return

	if not is_instance_valid(_current_target):
		return

	# Change target to follow based on priority, doesn't change if no higher priority
	var target_to_follow := _current_target
	for next_target in _targets.keys():
		var current_priority := _targets[target_to_follow]
		var next_priority := _targets[next_target]

		if next_priority > current_priority:
			target_to_follow = next_target

	follow_target = target_to_follow
	_log()


func _log() -> void:
	Debug.log("Moving camera to %s" % follow_target.name)


func _on_request_follow(target: Node2D, follow_priority: Priority) -> void:
	_targets[target] = follow_priority
	_update_camera()


func _on_revoke_follow(target: Node2D) -> void:
	_targets.erase(target)
	_update_camera()


func _on_update_timer_timeout() -> void:
	_update_camera()
