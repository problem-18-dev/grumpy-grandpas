class_name PlayerHUD
extends CanvasLayer

signal weapon_selected(weapon: WeaponResource)

const WEAPONS_CATALOGUE = preload("uid://b4umg781jsip2")
const INVENTORY_WEAPON_BUTTON_VARIANT := "InventoryWeaponButton"

var _selected_weapon: WeaponResource = Player.DEFAULT_WEAPON

@onready var weapons_grid: GridContainer = $WeaponsGrid


func _ready() -> void:
	_spawn_weapons_buttons()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			close()
			return

		open()


func open() -> void:
	_disable_selected_weapon()
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
		button.name = weapon.name
		weapons_grid.add_child(button)


func _disable_selected_weapon() -> void:
	for button in weapons_grid.get_children():
		if button.name == _selected_weapon.name:
			button.disabled = true
			continue

		button.disabled = false


func _on_button_pressed(weapon: WeaponResource) -> void:
	weapon_selected.emit(weapon)
	_selected_weapon = weapon
	close()
