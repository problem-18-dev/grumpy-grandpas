class_name PlayerHUD
extends CanvasLayer

signal item_selected(item: ItemResource)

const CATALOGUE = preload("uid://gr6x0tlr2xog")
const INVENTORY_ITEM_BUTTON_VARIANT := "InventoryItemButton"

var _item_buttons: Dictionary[ItemResource, Button]

@onready var weapons_grid: GridContainer = %WeaponsGrid
@onready var tools_grid: GridContainer = %ToolsGrid
@onready var tools_label: Label = %ToolsLabel


func _ready() -> void:
	_spawn_weapon_buttons()
	_spawn_tool_buttons()


func open(locked_items: Array[ItemResource], equipped_item: ItemResource) -> void:
	_update_locked_items(locked_items)
	_disable_equipped_item_button(equipped_item)
	show()


func close() -> void:
	hide()


func _update_locked_items(new_locked_items: Array[ItemResource]) -> void:
	if new_locked_items.is_empty():
		_unlock_all()
		return

	for item: ItemResource in _item_buttons.keys():
		if not new_locked_items.has(item):
			_unlock_button(item)
			continue

		_lock_button(item)


func _spawn_weapon_buttons() -> void:
	var weapons := CATALOGUE.weapons

	for weapon in weapons:
		var button := Button.new()
		button.theme_type_variation = INVENTORY_ITEM_BUTTON_VARIANT
		button.pressed.connect(_on_button_pressed.bind(weapon))
		button.text = weapon.name
		weapons_grid.add_child(button)
		_item_buttons[weapon] = button


func _spawn_tool_buttons() -> void:
	var tools := CATALOGUE.tools

	for tool in tools:
		var button := Button.new()
		button.theme_type_variation = INVENTORY_ITEM_BUTTON_VARIANT
		button.pressed.connect(_on_button_pressed.bind(tool))
		button.text = tool.name
		tools_grid.add_child(button)
		_item_buttons[tool] = button


func _disable_equipped_item_button(equipped_item: ItemResource) -> void:
	_item_buttons[equipped_item].disabled = true


func _unlock_all() -> void:
	for item in _item_buttons.keys():
		_unlock_button(item)


func _unlock_button(item: ItemResource) -> void:
	var button := _item_buttons[item]
	button.disabled = false
	button.text = item.name


## TODO: Implement special locked state
func _lock_button(item: ItemResource) -> void:
	var button := _item_buttons[item]
	button.disabled = true
	button.text = item.name + " (locked)"


func _on_button_pressed(item: ItemResource) -> void:
	close()
	item_selected.emit(item)
