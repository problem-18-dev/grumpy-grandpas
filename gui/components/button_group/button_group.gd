@tool
extends Node

signal button_pressed(button: BaseButton)


func _ready() -> void:
	var button_group := ButtonGroup.new()
	button_group.pressed.connect(button_pressed.emit)

	for child: BaseButton in get_children():
		child.button_group = button_group


func _get_configuration_warnings() -> PackedStringArray:
	var children := get_children()
	var errors: PackedStringArray = []

	if children.is_empty():
		errors.append("ButtonGroup must have at least 1 BaseButton.")

	for child in get_children():
		if child is not BaseButton:
			errors.append("ButtonGroup must only have BaseButtons as children.")
			break

	return errors
