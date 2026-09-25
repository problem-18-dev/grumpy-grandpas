class_name GameConfigurator
extends RefCounted

const TEAM_DEFAULT_BLUE_UID = "uid://ch58ix0v1k12m"
const TEAM_DEFAULT_RED_UID = "uid://bk7c7sch2hnip"
const QUICKPLAY_CATALOGUE_UID = "uid://bl3irmmkftpba"

const TEAM_TUTORIAL_BLUE_UID = "uid://cgtof6pv3rtlo"
const TEAM_TUTORIAL_RED_UID = "uid://ci6lhhlkv6opp"
const TUTORIAL_CATALOGUE_UID = "uid://c0onk6kmhoekl"

enum Preset {
	QUICK_PLAY,
	TUTORIAL,
}

const PRESETS := {
	Preset.QUICK_PLAY: {
		"teams": [TEAM_DEFAULT_BLUE_UID, TEAM_DEFAULT_RED_UID],
		"catalogue": QUICKPLAY_CATALOGUE_UID,
	},
	Preset.TUTORIAL: {
		"teams": [TEAM_TUTORIAL_BLUE_UID, TEAM_TUTORIAL_RED_UID],
		"catalogue": TUTORIAL_CATALOGUE_UID,
	},
}


static func load_preset(new_preset: Preset) -> void:
	GameManager.reset()

	var preset: Dictionary = PRESETS[new_preset]
	for team_uid: String in preset["teams"]:
		GameManager.add_team(load(team_uid).duplicate_deep())
	GameManager.set_catalogue(load(preset["catalogue"]).duplicate_deep())


## TODO: Level
static func load_custom(teams: Array[TeamResource], catalogue: CatalogueResource) -> void:
	GameManager.reset()

	for team in teams:
		GameManager.add_team(team.duplicate_deep())
	GameManager.set_catalogue(catalogue.duplicate_deep())
