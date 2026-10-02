class_name HUD
extends Control

const WHITE_COLOR := Color(1.0, 1.0, 1.0, 1.0)

var _timer_blink_tween: Tween

# General HUD
@onready var message_label: Label = %MessageLabel
@onready var turn_timer_label: Label = %TurnTimerLabel
@onready var turn_timer_panel: Panel = $MarginContainer/TurnTimerPanel

# Player HUD
@onready var item_container: VBoxContainer = %ItemContainer
@onready var item_name_label: Label = %ItemNameLabel
@onready var item_texture: TextureRect = %ItemTexture
@onready var ammo_label: Label = %AmmoLabel
@onready var camera_container: HBoxContainer = %CameraContainer


func _ready() -> void:
	turn_timer_panel.hide()


func set_message(message: String, duration := 0.0, color := WHITE_COLOR) -> void:
	message_label.text = message
	message_label.add_theme_color_override("font_color", color)

	if duration > 0:
		await get_tree().create_timer(duration, false).timeout
		message_label.text = ""
		message_label.remove_theme_color_override("font_color")


func set_turn_timer(value: int, is_urgent: bool) -> void:
	turn_timer_panel.show()
	turn_timer_label.text = str(value)
	_handle_timer_blink(is_urgent)


func set_item(item: ItemResource) -> void:
	item_name_label.text = item.name
	item_texture.texture = item.icon
	item_container.show()
	set_item_ammo(item.aimable_resource.ammo, item.aimable_resource.ammo)


func set_item_ammo(current_ammo: int, max_ammo: int) -> void:
	if max_ammo <= 0:
		ammo_label.hide()
		return

	ammo_label.text = _get_ammo_label(current_ammo, max_ammo)


func show_camera_shortcut() -> void:
	_toggle_camera_shortcut(true)


func hide_camera_shortcut() -> void:
	_toggle_camera_shortcut(false)


func _handle_timer_blink(enable: bool) -> void:
	if not enable:
		turn_timer_label.show()
		if _timer_blink_tween and _timer_blink_tween.is_running():
			_timer_blink_tween.kill()
		return

	if enable and _timer_blink_tween and _timer_blink_tween.is_running():
		return

	_timer_blink_tween = create_tween().set_loops()
	_timer_blink_tween.tween_callback(_toggle_timer_label).set_delay(0.25)


func _toggle_timer_label() -> void:
	turn_timer_label.visible = not turn_timer_label.visible


func _toggle_camera_shortcut(value: bool) -> void:
	camera_container.visible = value


func _get_ammo_label(current_ammo: int, max_ammo: int) -> String:
	current_ammo = maxi(0, current_ammo)
	max_ammo = maxi(1, max_ammo)
	return "%s/%s" % [current_ammo, max_ammo]
