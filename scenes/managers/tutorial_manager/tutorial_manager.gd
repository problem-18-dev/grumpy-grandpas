class_name TutorialManager
extends Node

signal phase_started(phase: Phase)

enum Phase {
	INTRO,
	MOVE,
	JUMP,
	AIM,
	SHOOT,
	PICK_UP,
	INVENTORY,
	ENEMY_DEATH,
	OUTRO,
	CAMERA,
}

## Requirements are in key code
const PHASE_KEY_EVENT_REQUIREMENTS := {
	Phase.MOVE: ["left", "right"],
	Phase.JUMP: ["x"],
	Phase.AIM: ["up", "down"],
	Phase.INVENTORY: ["i"],
}

const PHASE_KEY_EVENT_ALLOWED: Dictionary[Phase, Array] = {
	Phase.MOVE: ["move_left", "move_right"],
	Phase.JUMP: ["jump"],
	Phase.AIM: ["up", "down"],
	Phase.SHOOT: ["shoot"],
	Phase.INVENTORY: ["inventory"],
}

@export var initial_phase: Phase

var current_phase: Phase

var _phase_order: Array[Phase] = [
	Phase.INTRO,
	Phase.MOVE,
	Phase.JUMP,
	Phase.AIM,
	Phase.SHOOT,
	Phase.CAMERA,
	Phase.PICK_UP,
	Phase.INVENTORY,
	Phase.ENEMY_DEATH,
	Phase.OUTRO,
]
var _recorded: Array[String] = []


func start() -> void:
	current_phase = initial_phase
	_handle_input_blocking(current_phase)
	phase_started.emit(current_phase)


func next_phase() -> void:
	_recorded.clear()

	var index := _phase_order.find(current_phase) + 1
	current_phase = _phase_order[clampi(index, 0, _phase_order.size() - 1)]

	_handle_input_blocking(current_phase)

	phase_started.emit(current_phase)


func record_key_event(event: InputEventKey) -> void:
	if not PHASE_KEY_EVENT_REQUIREMENTS.keys().has(current_phase):
		return

	var input := event.as_text().to_lower()
	var requirements: Array = PHASE_KEY_EVENT_REQUIREMENTS[current_phase]

	if not requirements.has(input):
		return

	if not _recorded.has(input):
		_recorded.append(input)

	var phase_complete: bool = PHASE_KEY_EVENT_REQUIREMENTS[current_phase].all(
		func(r: String) -> bool:
			return _recorded.has(r),
	)

	if not phase_complete:
		return

	next_phase()


func _handle_input_blocking(phase: Phase) -> void:
	InputGate.block_all()

	var previous_phases: Array[Phase] = _phase_order.slice(0, phase + 1)

	@warning_ignore("int_as_enum_without_cast")
	for previous_phase: Phase in previous_phases:
		if previous_phase in PHASE_KEY_EVENT_ALLOWED.keys():
			var allowed_inputs := PHASE_KEY_EVENT_ALLOWED[previous_phase]
			InputGate.allow_some(allowed_inputs)
