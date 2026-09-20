extends TutorialState


func enter(data := { }) -> void:
	super(data)
	EventSystem.camera.revoke_manual.connect(_on_camera_revoke_manual, CONNECT_ONE_SHOT)


func _start() -> void:
	super()
	InputGate.allow_some(["move_left", "move_right", "jump", "up", "down", "camera"])


func _on_camera_revoke_manual() -> void:
	_next_phase()
