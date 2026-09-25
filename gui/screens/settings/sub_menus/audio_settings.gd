extends MarginContainer

const MUTE_TRESHOLD := 0.05
const MASTER_BUS := 0
const SFX_BUS := 1

@onready var master_slider: HSlider = %MasterSlider
@onready var sfx_slider: HSlider = %SFXSlider


func _ready() -> void:
	_load_saved_values()


func _load_saved_values() -> void:
	master_slider.set_value_no_signal(SettingsManager.save.master_volume)
	sfx_slider.set_value_no_signal(SettingsManager.save.sfx_volume)


func _save_values() -> void:
	SettingsManager.save_master_volume(master_slider.value)
	SettingsManager.save_sfx_volume(sfx_slider.value)


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
