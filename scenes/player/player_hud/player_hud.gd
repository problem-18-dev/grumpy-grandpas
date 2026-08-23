class_name PlayerHUD
extends CanvasLayer

signal item_selected(item: ItemResource)

const ITEM_CATALOGUE = preload("uid://b4umg781jsip2")
const INVENTORY_ITEM_BUTTON_VARIANT := "InventoryItemButton"

var _buttons: Dictionary[ItemResource, Button]

@onready var weapons_grid: GridContainer = %WeaponsGrid
@onready var tools_grid: GridContainer = %ToolsGrid
@onready var tools_label: Label = %ToolsLabel


func _ready() -> void:
	_spawn_weapon_buttons()
	_spawn_tool_buttons()


func open(equipped_item: ItemResource) -> void:
	_update_buttons(equipped_item)
	show()


func close() -> void:
	hide()


func _spawn_weapon_buttons() -> void:
	var weapons := ITEM_CATALOGUE.weapons

	for weapon in weapons:
		var button := Button.new()
		button.theme_type_variation = INVENTORY_ITEM_BUTTON_VARIANT
		button.pressed.connect(_on_button_pressed.bind(weapon))
		button.text = weapon.name
		weapons_grid.add_child(button)
		_buttons[weapon] = button


func _spawn_tool_buttons() -> void:
	var tools := ITEM_CATALOGUE.tools

	for tool in tools:
		var button := Button.new()
		button.theme_type_variation = INVENTORY_ITEM_BUTTON_VARIANT
		button.pressed.connect(_on_button_pressed.bind(tool))
		button.text = tool.name
		tools_grid.add_child(button)
		_buttons[tool] = button


func _update_buttons(equipped_item: ItemResource) -> void:
	for button in _buttons.values():
		button.disabled = false

	_buttons[equipped_item].disabled = true


func _on_button_pressed(item: ItemResource) -> void:
	close()
	item_selected.emit(item)
