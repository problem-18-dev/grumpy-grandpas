extends TutorialState


func _start() -> void:
	super()
	InputGate.allow_some(["move_left", "move_right", "jump"])
	tutorial.create_keycaps("x")
