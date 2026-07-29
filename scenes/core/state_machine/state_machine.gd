class_name StateMachine
extends Node

@export_group("Properties")
@export var initial_state: State
@export_group("Debug")
@export var debug_enabled := false

@onready var _state := initial_state


func _ready() -> void:
	await owner.ready

	for state: State in find_children("*", "State"):
		state.finished.connect(transition_to_state)

	_state.enter()


func _process(delta: float) -> void:
	_state._update(delta)


func _physics_process(delta: float) -> void:
	_state._physics_update(delta)


func _unhandled_key_input(event: InputEvent) -> void:
	_state._key_input(event)


func transition_to_state(state: String, data := { }) -> void:
	var new_state := get_node(state)
	assert(new_state, "Transition to state %s failed" % state)

	_state.exit()
	_state = new_state
	_state.enter(data)

	if not debug_enabled:
		return

	if data.size() > 0:
		Debug.log("%s state changed to %s with %s" % [owner.name, state, data])
		return

	Debug.log("%s state changed to %s" % [owner.name, state])
