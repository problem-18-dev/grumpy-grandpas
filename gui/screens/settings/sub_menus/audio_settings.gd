extends MarginContainer

const MUTE_TRESHOLD := 0.05
const MASTER_BUS := 0
const SFX_BUS := 1
const MUSIC_BUS := 2
const GUI_BUS := 3

@onready var master_slider: HSlider = %MasterSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var gui_slider: HSlider = %GUISlider


func _ready() -> void:
	_load_saved_values()


func _load_saved_values() -> void:
	master_slider.set_value_no_signal(SettingsSaveManager.save.master_volume)
	sfx_slider.set_value_no_signal(SettingsSaveManager.save.sfx_volume)
	music_slider.set_value_no_signal(SettingsSaveManager.save.music_volume)
	gui_slider.set_value_no_signal(SettingsSaveManager.save.gui_volume)


func _save_values() -> void:
	SettingsSaveManager.save_master_volume(master_slider.value)
	SettingsSaveManager.save_sfx_volume(sfx_slider.value)
	SettingsSaveManager.save_music_volume(music_slider.value)
	SettingsSaveManager.save_gui_volume(gui_slider.value)


func _change_volume(value: float, bus: int) -> void:
	if value < MUTE_TRESHOLD:
		AudioServer.set_bus_mute(bus, true)
		return

	AudioServer.set_bus_mute(bus, false)
	AudioServer.set_bus_volume_linear(bus, value)


func _on_master_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return

	_change_volume(master_slider.value, MASTER_BUS)
	_save_values()


func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return

	_change_volume(sfx_slider.value, SFX_BUS)
	_save_values()


func _on_music_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return

	_change_volume(music_slider.value, MUSIC_BUS)
	_save_values()


func _on_gui_slider_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return

	_change_volume(gui_slider.value, GUI_BUS)
	_save_values()
