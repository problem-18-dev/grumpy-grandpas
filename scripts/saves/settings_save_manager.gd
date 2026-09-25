class_name SettingsSaveManager
extends Object

static var save: SettingsSaveResource = null


static func load_settings() -> void:
	var save_exists := ResourceLoader.exists(SettingsSaveResource.SAVE_PATH)

	if not save_exists:
		save = SettingsSaveResource.new()
		return

	save = ResourceLoader.load(SettingsSaveResource.SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)


static func save_sfx_volume(value: float) -> void:
	save.sfx_volume = value
	ResourceSaver.save(save, SettingsSaveResource.SAVE_PATH)


static func save_master_volume(value: float) -> void:
	save.master_volume = value
	ResourceSaver.save(save, SettingsSaveResource.SAVE_PATH)
