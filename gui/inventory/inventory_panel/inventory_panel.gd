@tool
class_name InventoryPanel
extends Panel

signal item_selected(item: ItemResource)

const ITEM_UID := "uid://detbmroxfa70l"

@export var title := "Panel"

@onready var title_label: Label = %TitleLabel
@onready var button_container: VBoxContainer = %ButtonContainer


func _ready() -> void:
	title_label.text = title


func add_item(item: ItemResource) -> Button:
	var button: Button = load(ITEM_UID).instantiate()
	button.text = item.name
	button.pressed.connect(item_selected.emit.bind(item))
	button_container.add_child(button)
	return button
