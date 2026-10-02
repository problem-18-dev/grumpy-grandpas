@tool
class_name Keycap
extends Control

@export var text: String = "W"
@export_group("Animation")
@export var should_animate := true

@onready var label: Label = $Background/Foreground/Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	label.text = text

	if not should_animate:
		animation_player.play("RESET")
