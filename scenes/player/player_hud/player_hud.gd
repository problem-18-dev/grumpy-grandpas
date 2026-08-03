class_name PlayerHUD
extends CanvasLayer

signal weapon_selected(weapon: WeaponResource)

const WEAPONS_CATALOGUE = preload("uid://b4umg781jsip2")
const INVENTORY_WEAPON_BUTTON_VARIANT := "InventoryWeaponButton"

var _buttons: Dictionary[WeaponResource, Button]

@onready var weapons_grid: GridContainer = $WeaponsGrid


func _ready() -> void:
	_spawn_weapons_buttons()


func open(equipped_weapon: WeaponResource) -> void:
	_update_buttons(equipped_weapon)
	show()


func close() -> void:
	hide()


func _spawn_weapons_buttons() -> void:
	var weapons := WEAPONS_CATALOGUE.weapons

	for weapon in weapons:
		var button := Button.new()
		button.theme_type_variation = INVENTORY_WEAPON_BUTTON_VARIANT
		button.pressed.connect(_on_button_pressed.bind(weapon))
		button.text = weapon.name
		weapons_grid.add_child(button)
		_buttons[weapon] = button


func _update_buttons(equipped_weapon: WeaponResource) -> void:
	for button in _buttons.values():
		button.disabled = false

	_buttons[equipped_weapon].disabled = true


func _on_button_pressed(weapon: WeaponResource) -> void:
	weapon_selected.emit(weapon)
	close()
