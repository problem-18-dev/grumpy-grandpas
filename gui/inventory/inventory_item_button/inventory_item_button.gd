class_name InventoryItemButton
extends Button

@onready var locked_panel: Panel = $LockedPanel


func lock() -> void:
	disabled = true
	locked_panel.show()


func unlock() -> void:
	disabled = false
	locked_panel.hide()
