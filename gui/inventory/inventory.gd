class_name Inventory
extends Control

## Emits when inventory is closed, optionally provides which item was chosen
signal closed(item: ItemResource)

var _item_buttons: Dictionary[ItemResource, InventoryItemButton]
var _item_tween: Tween

@onready var items_panel: InventoryPanel = %ItemsPanel
@onready var item_name_label: Label = %ItemNameLabel
@onready var item_info_label: Label = %ItemInfoLabel


func _ready() -> void:
	_spawn_weapon_buttons()
	_spawn_tool_buttons()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		closed.emit()
		queue_free()
		get_viewport().set_input_as_handled()


func open(locked_items: Array[ItemResource], equipped_item: ItemResource) -> void:
	_update_locked_items(locked_items)
	_disable_equipped_item_button(equipped_item)


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
	var weapons: Array[ItemResource] = GameManager.get_catalogue().weapons

	for weapon: ItemResource in weapons:
		var button := items_panel.add_item(weapon, InventoryPanel.Section.WEAPONS)
		_item_buttons[weapon] = button


func _spawn_tool_buttons() -> void:
	var tools: Array[ItemResource] = GameManager.get_catalogue().tools

	for tool: ItemResource in tools:
		var button := items_panel.add_item(tool, InventoryPanel.Section.TOOLS)
		_item_buttons[tool] = button


func _disable_equipped_item_button(equipped_item: ItemResource) -> void:
	_item_buttons[equipped_item].disabled = true


func _unlock_all() -> void:
	for item: ItemResource in _item_buttons.keys():
		_unlock_button(item)


func _unlock_button(item: ItemResource) -> void:
	var button: InventoryItemButton = _item_buttons[item]
	button.unlock()


func _lock_button(item: ItemResource) -> void:
	var button: InventoryItemButton = _item_buttons[item]
	button.lock()


func _on_panel_item_selected(item: ItemResource) -> void:
	closed.emit(item)
	queue_free()


func _on_items_panel_item_hovered(hover: bool, item: ItemResource) -> void:
	if not hover:
		_item_tween.kill()
		item_name_label.text = ""
		item_info_label.text = ""
		return

	_item_tween = create_tween().set_parallel()
	_item_tween.tween_property(item_name_label, "modulate:a", 1.0, 0.25).from(0.5)
	_item_tween.tween_property(item_info_label, "modulate:a", 1.0, 0.25).from(0.5)

	item_name_label.text = item.name
	item_info_label.text = item.description
