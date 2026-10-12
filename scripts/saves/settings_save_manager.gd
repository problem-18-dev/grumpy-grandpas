class_name SettingsSaveManager
extends Object

static var save: SettingsSaveResource = null


static func load_settings() -> void:
	var save_exists := ResourceLoader.exists(SettingsSaveResource.SAVE_PATH)

	if not save_exists:
		save = SettingsSaveResource.new()
		return

	save = ResourceLoader.load(SettingsSaveResource.SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	AudioServer.set_bus_volume_linear(0, save.master_volume)
	AudioServer.set_bus_volume_linear(1, save.sfx_volume)
	AudioServer.set_bus_volume_linear(2, save.music_volume)
	AudioServer.set_bus_volume_linear(3, save.gui_volume)


static func save_sfx_volume(value: float) -> void:
	save.sfx_volume = value
	ResourceSaver.save(save, SettingsSaveResource.SAVE_PATH)


static func save_master_volume(value: float) -> void:
	save.master_volume = value
	ResourceSaver.save(save, SettingsSaveResource.SAVE_PATH)


static func save_gui_volume(value: float) -> void:
	save.gui_volume = value
	ResourceSaver.save(save, SettingsSaveResource.SAVE_PATH)


static func save_music_volume(value: float) -> void:
	save.music_volume = value
	ResourceSaver.save(save, SettingsSaveResource.SAVE_PATH)
