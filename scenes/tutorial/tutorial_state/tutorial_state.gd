@abstract
class_name TutorialState
extends State

enum Phase {
	INTRO,
	MOVE,
	JUMP,
	AIM,
	CAMERA,
	SHOOT,
	PICKUPPABLE,
	INVENTORY,
	ENEMY_DEATH,
	OUTRO,
}

const PHASES := {
	Phase.INTRO: "Intro",
	Phase.MOVE: "Move",
	Phase.JUMP: "Jump",
	Phase.AIM: "Aim",
	Phase.CAMERA: "Camera",
	Phase.SHOOT: "Shoot",
	Phase.PICKUPPABLE: "Pickuppable",
	Phase.INVENTORY: "Inventory",
	Phase.ENEMY_DEATH: "EnemyDeath",
	Phase.OUTRO: "Outro",
}

@export var announcements: Array[String]
@export var key_requirements: Array[Key]
@export var next_phase: Phase

var tutorial: Tutorial

var _announcement_pointer := 0
var _registered_keys: Array[Key]


func _ready() -> void:
	assert(owner is Tutorial, "Tutorial state not owned by tutorial")
	tutorial = owner


func enter(_data := { }) -> void:
	_announcement_pointer = 0
	_registered_keys.clear()

	tutorial.clear_keycaps()
	tutorial.show_announcement(announcements[0])

	if announcements.size() > 1:
		tutorial.continue_label.show()
		return

	tutorial.continue_label.hide()
	_start()


func exit() -> void:
	tutorial.clear_keycaps()


func _key_input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm") and _can_continue():
		_continue()

	_register_key(event)


func _start() -> void:
	tutorial.activate_player()


func _continue() -> void:
	_announcement_pointer += 1
	tutorial.show_announcement(announcements[_announcement_pointer])

	if not _can_continue():
		tutorial.continue_label.hide()
		_start()


func _can_continue() -> bool:
	return _announcement_pointer != announcements.size() - 1


func _register_key(event: InputEventKey) -> void:
	if not event.is_pressed() or key_requirements.is_empty():
		return

	var event_key := event.keycode

	if key_requirements.has(event_key) and not _registered_keys.has(event_key):
		_registered_keys.append(event_key)

		if _registered_keys.size() != key_requirements.size():
			return

		var completed := _registered_keys.all(
			func(k: Key) -> bool:
				return key_requirements.has(k),
		)

		if completed:
			_next_phase()


func _next_phase() -> void:
	finished.emit(PHASES[next_phase])
	tutorial.initial_phase = next_phase
