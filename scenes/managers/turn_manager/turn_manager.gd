class_name TurnManager
extends Node2D

signal turn_started(player: Player)
signal turn_ended(player: Player)
signal match_ended(winner: TeamResource)

var _teams: Array[Team] = []
var _active_team: Team
var _active_player: Player
var _players_marked_for_death: Array[Player]


func start() -> void:
	assert(not _teams.is_empty(), "No teams to start with.")

	_start_turn()


func assign_player(team_resource: TeamResource, player: Player) -> void:
	add_child(player)
	player.marked_for_death.connect(_on_players_marked_for_death)

	_get_or_create_team(team_resource).add(player)


func next_turn() -> void:
	await _cleanup()
	turn_ended.emit(_active_player)

	_next_team()
	_start_turn()


func _start_turn() -> void:
	if _teams.size() > 1:
		_active_team = _current_team()
		_active_player = _active_team.current_player()
		_active_player.activate()
		turn_started.emit(_active_player)
		return

	var winner := _current_team().resource if not _teams.is_empty() else null
	match_ended.emit(winner)


func _cleanup() -> void:
	if is_instance_valid(_active_player):
		_active_player.deactivate()

	for player in _players_marked_for_death:
		if not is_instance_valid(player):
			continue

		player.die()
		await player.died

	_players_marked_for_death = []


func _next_team() -> void:
	if _current_team() != _active_team:
		return

	_active_team.next_player(_active_player)
	_teams.push_back(_teams.pop_front())


func _current_team() -> Team:
	return _teams.front()


func _get_or_create_team(team_resource: TeamResource) -> Team:
	for team in _teams:
		if team.resource == team_resource:
			return team

	var new_team := Team.new(team_resource)
	_teams.append(new_team)
	return new_team


func _on_players_marked_for_death(player: Player) -> void:
	if player == _active_player:
		_active_player = null

	_players_marked_for_death.append(player)

	for team in _teams:
		team.kill(player)

		if team.has_lost():
			_teams.erase(team)
			break


class Team:
	var resource: TeamResource

	var _players: Array[Player] = []


	func _init(team_resource: TeamResource) -> void:
		resource = team_resource


	func add(player: Player) -> void:
		_players.append(player)


	func current_player() -> Player:
		return _players.front()


	func has_lost() -> bool:
		return _players.is_empty()


	func kill(player: Player) -> void:
		_players.erase(player)


	func next_player(after: Player) -> void:
		if _players.front() == after:
			_players.push_back(_players.pop_front())
