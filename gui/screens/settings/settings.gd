extends Control

const MAIN_MENU_UID = "uid://b2d8kklebnhfj"

@onready var audio_button: Button = %AudioButton
@onready var back_button: Button = %BackButton
@onready var title_label: Label = %TitleLabel
@onready var sub_menu_panel: Panel = %SubMenuPanel
@onready var sub_menus := { audio_button: { "title": "Audio", "menu": %AudioSettings } }


func _ready() -> void:
	_group_buttons()
	audio_button.button_pressed = true


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_quit"):
		_on_back_button_pressed()


func _group_buttons() -> void:
	var button_group := ButtonGroup.new()
	button_group.pressed.connect(_on_button_group_button_pressed)

	audio_button.button_group = button_group


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_UID)


func _on_button_group_button_pressed(button: BaseButton) -> void:
	for sub_menu in sub_menu_panel.get_children():
		sub_menu.hide()

	var sub_menu_data: Dictionary = sub_menus[button]
	title_label.text = sub_menu_data.title
	sub_menu_data.menu.show()
