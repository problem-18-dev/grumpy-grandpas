class_name CustomGameSaveManager
extends Object

const MAX_TEAMS := 4

static var save: CustomGameSaveResource = null


static func load_settings() -> void:
	var save_exists := ResourceLoader.exists(CustomGameSaveResource.SAVE_PATH)

	if not save_exists:
		save = CustomGameSaveResource.new()
		return

	save = ResourceLoader.load(
		CustomGameSaveResource.SAVE_PATH,
		"",
		ResourceLoader.CACHE_MODE_IGNORE,
	)


static func get_all() -> CustomGameSaveResource:
	return save


static func get_teams() -> Array[TeamResource]:
	return save.teams


static func add_team(team: TeamResource) -> void:
	save.teams.append(team)
	_save()


static func set_catalogue(catalogue: CatalogueResource) -> void:
	save.catalogue = catalogue
	_save()


static func set_level(level: String) -> void:
	save.level = level
	_save()


static func teams_is_full() -> bool:
	return save.teams.size() >= MAX_TEAMS


static func remove_team(team: TeamResource) -> void:
	save.teams.erase(team)
	_save()


static func _save() -> void:
	ResourceSaver.save(save, CustomGameSaveResource.SAVE_PATH)
