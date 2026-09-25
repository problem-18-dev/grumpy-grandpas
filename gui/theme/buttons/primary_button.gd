extends HBoxContainer

@export var text: String = "Test setting."

@onready var label: Label = $Label


func _on_button_focus_entered() -> void:
	label.show()


func _on_button_focus_exited() -> void:
	label.hide()
