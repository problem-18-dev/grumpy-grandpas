extends TutorialState


func _start() -> void:
	super()
	InputGate.allow_some(["move_left", "move_right"])
	tutorial.create_keycaps("←", "→")
