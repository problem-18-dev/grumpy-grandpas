class_name Inventory
extends Control

## Emits when inventory is closed, optionally provides which item was chosen
signal closed(item: ItemResource)

var _item_buttons: Dictionary[ItemResource, Button]

@onready var weapons_panel: InventoryPanel = %WeaponsPanel
@onready var tools_panel: InventoryPanel = %ToolsPanel


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
		var button := weapons_panel.add_item(weapon)
		_item_buttons[weapon] = button


func _spawn_tool_buttons() -> void:
	var tools: Array[ItemResource] = GameManager.get_catalogue().tools

	for tool: ItemResource in tools:
		var button := tools_panel.add_item(tool)
		_item_buttons[tool] = button


func _disable_equipped_item_button(equipped_item: ItemResource) -> void:
	_item_buttons[equipped_item].disabled = true


func _unlock_all() -> void:
	for item: ItemResource in _item_buttons.keys():
		_unlock_button(item)


func _unlock_button(item: ItemResource) -> void:
	var button: Button = _item_buttons[item]
	button.disabled = false
	button.text = item.name


func _lock_button(item: ItemResource) -> void:
	var button: Button = _item_buttons[item]
	button.disabled = true
	button.text = item.name + " (locked)"


func _on_panel_item_selected(item: ItemResource) -> void:
	closed.emit(item)
	queue_free()
