@tool
class_name Keycap
extends Control

@export var text: String = "W"

@onready var label: Label = $Background/Foreground/Label


func _ready() -> void:
	label.text = text
