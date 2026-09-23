class_name InventoryItemButton
extends Button

const EQUIPPED_COLOR := Color(1.0, 0.922, 0.2, 1.0)

@onready var locked_panel: Panel = $LockedPanel


func mark_equipped() -> void:
	disabled = true
	add_theme_color_override("font_disabled_color", EQUIPPED_COLOR)


func lock() -> void:
	disabled = true
	locked_panel.show()


func unlock() -> void:
	disabled = false
	locked_panel.hide()
