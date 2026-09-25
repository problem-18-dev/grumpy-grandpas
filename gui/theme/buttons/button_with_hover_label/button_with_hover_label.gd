@tool
extends HBoxContainer

@export var hover_label_text: String
@export var button_text: String

@onready var button: Button = $Button
@onready var label: Label = $Label


func _ready() -> void:
	button.text = button_text
	label.text = hover_label_text


func _on_button_mouse_entered() -> void:
	label.show()


func _on_button_mouse_exited() -> void:
	label.hide()
