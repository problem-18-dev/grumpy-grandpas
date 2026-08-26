class_name PlayersManager
extends Node2D

const PLAYER := preload("uid://bmag23mf230r3")

var teams: Array[TeamResource] = []
var active_team: TeamResource
var active_player: Player
var players_marked_for_death: Array[Player]


func spawn_players(spawn_points: Array[Dictionary]) -> void:
	for team in GameManager.get_teams():
		for player_resource in team.player_resources:
			var player: Player = PLAYER.instantiate()
			add_child(player)

			var spawn_data: Dictionary = spawn_points.pop_back()
			player.spawn(spawn_data.get("spawn_position"), spawn_data.get("spawn_normal"))
			player.setup(team, player_resource)

			player.marked_for_death.connect(_on_player_marked_for_death)
			player.requested_catalogue.connect(_on_player_requested_catalogue)

			get_or_create_team(team).add_player(player)


func activate_player() -> Player:
	active_team = current_team()
	active_player = active_team.current_player()
	active_player.activate()
	return active_player


func heal_player(player_to_heal: Player) -> void:
	player_to_heal.heal()


func kill_marked_players() -> void:
	if is_instance_valid(active_player):
		active_player.deactivate()

	for player in players_marked_for_death:
		if not is_instance_valid(player):
			continue

		player.die()
		await player.died

	players_marked_for_death = []


func next_team() -> void:
	if current_team() != active_team:
		return

	active_team.next_player(active_player)
	teams.push_back(teams.pop_front())


func current_team() -> TeamResource:
	return teams.front()


func get_or_create_team(team_resource: TeamResource) -> TeamResource:
	for team in teams:
		if team == team_resource:
			return team

	teams.append(team_resource)
	return team_resource


func unlock_random(category_items: Array) -> void:
	var team := current_team()
	var locked := team.get_locked_items().filter(
		func(item: ItemResource):
			return category_items.has(item),
	)

	if locked.is_empty():
		return

	team.unlock_item(locked.pick_random())


func unlock_weapon() -> void:
	unlock_random(GameManager.get_catalogue().weapons)


func unlock_tool() -> void:
	unlock_random(GameManager.get_catalogue().tools)


func get_winner() -> TeamResource:
	if teams.size() > 1:
		push_warning("Winner requested while more than 1 team remaining.")
		return

	return teams[0] if teams.size() == 1 else null


func _on_player_marked_for_death(player: Player) -> void:
	if player == active_player:
		active_player = null

	players_marked_for_death.append(player)

	for team in teams:
		team.kill_player(player)

		if team.has_lost():
			teams.erase(team)
			break


func _on_player_requested_catalogue(player: Player) -> void:
	var locked_items := current_team().get_locked_items()
	player.open_inventory(locked_items)
