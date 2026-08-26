extends Node

const TEAM_BLUE := preload("uid://qihimwpg1bn7")
const TEAM_RED := preload("uid://dejqu3g4sl2sc")

const DEFAULT_TEAMS: Array[TeamResource] = [TEAM_BLUE, TEAM_RED]
const DEFAULT_CATALOGUE: CatalogueResource = preload("uid://gr6x0tlr2xog")

var teams := DEFAULT_TEAMS
var catalogue := DEFAULT_CATALOGUE


func get_teams() -> Array[TeamResource]:
	return teams


func add_team(new_team: TeamResource) -> void:
	assert(new_team.players.size() > 0, "Team added without players")
	teams.append(new_team)


func get_catalogue() -> CatalogueResource:
	return catalogue
