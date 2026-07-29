@tool
extends CanvasLayer

const MAX_LOGS := 8

@export_group("Properties")
@export var enabled := true

@onready var content: VBoxContainer = $Background/Margin/Content


func _ready() -> void:
	if Engine.is_editor_hint():
		hide()

	if not enabled:
		queue_free()


func log(text: Variant) -> void:
	if content.get_child_count() > MAX_LOGS:
		content.get_child(0).queue_free()

	var label := Label.new()
	label.theme_type_variation = "DebugLabel"
	label.text = text
	content.add_child(label)
