extends Node

const MAX_TEAMS := 4
const DEFAULT_CATALOGUE: CatalogueResource = preload("uid://gr6x0tlr2xog")

var teams: Array[TeamResource] = []
var catalogue: CatalogueResource = DEFAULT_CATALOGUE


func reset() -> void:
	reset_teams()
	set_catalogue(DEFAULT_CATALOGUE)


func reset_teams() -> void:
	teams.clear()


func get_teams() -> Array[TeamResource]:
	return teams


func add_team(new_team: TeamResource) -> void:
	if is_full():
		push_warning("Teams is already 4, not adding.")
		return

	assert(new_team.player_resources.size() > 0, "Team added without players")
	teams.append(new_team)


func remove_team(team: TeamResource) -> void:
	teams.erase(team)


func is_full() -> bool:
	return teams.size() >= MAX_TEAMS


func set_catalogue(new_catalogue: CatalogueResource) -> void:
	catalogue = new_catalogue


func get_catalogue() -> CatalogueResource:
	return catalogue
