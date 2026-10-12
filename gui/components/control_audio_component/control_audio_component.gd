@tool
extends Node

const HOVER_SOUND_UID := "uid://c5ewrdyhcga8i"
const PRESS_SOUND_UID := "uid://dxwjroahld1fl"

@onready var control: Control = get_parent()


func _ready() -> void:
	control.mouse_entered.connect(_on_mouse_entered)

	if control is Button:
		control.pressed.connect(_on_mouse_pressed)


func _get_configuration_warnings() -> PackedStringArray:
	if not control or control is not Control:
		return ["Only compatible with a Control node."]
	return []


func _on_mouse_entered() -> void:
	var sound: AudioStream = load(HOVER_SOUND_UID)
	AudioManager.play_gui(sound)


func _on_mouse_pressed() -> void:
	var sound: AudioStream = load(PRESS_SOUND_UID)
	AudioManager.play_gui(sound)
