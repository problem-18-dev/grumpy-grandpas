extends TutorialState

@onready var players_manager: PlayersManager = %PlayersManager


func _start() -> void:
	super()
	InputGate.allow_some(["move_left", "move_right", "jump", "up", "down", "camera", "inventory"])
