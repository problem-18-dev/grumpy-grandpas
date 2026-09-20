extends TutorialState

@onready var pickuppable_manager: PickuppableManager = %PickuppableManager


func enter(data := { }) -> void:
	await tutorial.restart()
	tutorial.spawn_pickuppable()
	super(data)


func _start() -> void:
	super()
	InputGate.allow_some(["move_left", "move_right", "jump", "up", "down", "camera"])
	pickuppable_manager.picked_up.connect(_on_pickuppable_manager_picked_up, CONNECT_ONE_SHOT)


func _on_pickuppable_manager_picked_up(by: Player, type: PickuppableResource.Type) -> void:
	tutorial.players_manager.unlock_item(by, type)
	_next_phase()
