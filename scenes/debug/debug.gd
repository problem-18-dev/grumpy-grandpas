@tool
extends CanvasLayer

const MAX_LOGS := 8

@export_group("Properties")
@export var enabled := true

@onready var content: VBoxContainer = $Background/Margin/Content


func _ready() -> void:
	if Engine.is_editor_hint():
		hide()
		return

	if enabled and OS.is_debug_build():
		show()


func log(text: Variant) -> void:
	if not enabled:
		return

	if content.get_child_count() > MAX_LOGS:
		content.get_child(0).queue_free()

	var label := Label.new()
	label.theme_type_variation = "DebugLabel"
	label.text = text
	content.add_child(label)
