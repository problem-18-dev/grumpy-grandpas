extends TutorialState

@export var camera_control_announcement: String


func enter(data := { }) -> void:
	super(data)
	EventSystem.camera.revoke_manual.connect(_on_camera_revoke_manual, CONNECT_ONE_SHOT)


func _key_input(event: InputEvent) -> void:
	super(event)

	if event.is_action_pressed("camera") and not _can_continue():
		tutorial.show_announcement(camera_control_announcement)
		tutorial.create_keycaps("←", "↑", "→", "↓")


func _start() -> void:
	super()
	InputGate.allow_some(["move_left", "move_right", "jump", "up", "down", "camera"])
	tutorial.create_keycaps("c")


func _on_camera_revoke_manual() -> void:
	_next_phase()
