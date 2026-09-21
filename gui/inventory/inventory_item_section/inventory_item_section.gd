@tool
class_name InventoryItemSection
extends VBoxContainer

const ITEM_BUTTON := preload("uid://detbmroxfa70l")

@export var title := "Section"

@onready var title_label: Label = $TitleLabel
@onready var button_container: VBoxContainer = $ButtonContainer


func _ready() -> void:
	title_label.text = title


func add_item(item_name: String) -> InventoryItemButton:
	var button: InventoryItemButton = ITEM_BUTTON.instantiate()
	button.text = item_name
	button_container.add_child(button)
	return button
