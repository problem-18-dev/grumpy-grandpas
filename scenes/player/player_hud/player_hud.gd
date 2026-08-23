class_name PlayerHUD
extends CanvasLayer

signal aimable_selected(aimable: AimableResource)

const AIMABLE_CATALGOUE = preload("uid://b4umg781jsip2")
const INVENTORY_AIMABLE_BUTTON_VARIANT := "InventoryAimableButton"

var _buttons: Dictionary[AimableResource, Button]

@onready var weapons_grid: GridContainer = %WeaponsGrid
@onready var tools_grid: GridContainer = %ToolsGrid
@onready var tools_label: Label = %ToolsLabel


func _ready() -> void:
	_spawn_weapon_buttons()
	_spawn_tool_buttons()


func open(equipped_aimable: AimableResource) -> void:
	_update_buttons(equipped_aimable)
	show()


func close() -> void:
	hide()


func _spawn_weapon_buttons() -> void:
	var weapons := AIMABLE_CATALGOUE.weapons

	for weapon in weapons:
		var button := Button.new()
		button.theme_type_variation = INVENTORY_AIMABLE_BUTTON_VARIANT
		button.pressed.connect(_on_button_pressed.bind(weapon))
		button.text = weapon.name
		weapons_grid.add_child(button)
		_buttons[weapon] = button


func _spawn_tool_buttons() -> void:
	var tools := AIMABLE_CATALGOUE.tools

	for tool in tools:
		var button := Button.new()
		button.theme_type_variation = INVENTORY_AIMABLE_BUTTON_VARIANT
		button.pressed.connect(_on_button_pressed.bind(tool))
		button.text = tool.name
		tools_grid.add_child(button)
		_buttons[tool] = button


func _update_buttons(equipped_aimable: AimableResource) -> void:
	for button in _buttons.values():
		button.disabled = false

	_buttons[equipped_aimable].disabled = true


func _on_button_pressed(aimable: AimableResource) -> void:
	close()
	aimable_selected.emit(aimable)
