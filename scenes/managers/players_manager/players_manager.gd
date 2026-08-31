class_name PlayersManager
extends Node2D

signal player_finished

const PLAYER := preload("uid://bmag23mf230r3")

var teams: Array[TeamResource] = []
var active_team: TeamResource
var active_player: Player
var players_marked_for_death: Array[Player]
var players_to_damage: Array[Player]


func spawn_players(spawn_points: Array[Dictionary]) -> void:
	assert(spawn_points.size() > 0, "No spawn points provided.")
	assert(GameManager.get_teams().size() > 0, "No teams to spawn.")

	for team in GameManager.get_teams():
		for player_resource in team.player_resources:
			var player: Player = PLAYER.instantiate()
			add_child(player)

			var spawn_data: Dictionary = spawn_points.pop_back()
			player.spawn(spawn_data.get("spawn_position"), spawn_data.get("spawn_normal"))
			player.setup(team, player_resource)

			player.marked_for_death.connect(_on_player_marked_for_death)
			player.damage_accumulated.connect(_on_player_damage_accumulated)
			player.requested_catalogue.connect(_on_player_requested_catalogue)
			player.finished.connect(deactivate_player)

			_get_or_create_team(team).add_player(player)


func activate_player() -> void:
	active_team = _current_team()
	active_player = active_team.current_player()
	active_player.activate()
	EventSystem.camera.request_follow.emit(active_player, GameCamera.Priority.LOW)


func deactivate_player() -> void:
	if not is_instance_valid(active_player):
		return

	EventSystem.camera.revoke_follow.emit(active_player)
	active_player.deactivate()
	active_player = null
	player_finished.emit()


func kill_marked_players() -> void:
	if players_marked_for_death.is_empty():
		return

	for player in players_marked_for_death:
		if not is_instance_valid(player):
			continue

		await _kill_player(player)

	players_marked_for_death = []


func damage_players() -> void:
	if players_to_damage.is_empty():
		return

	for player in players_to_damage:
		await _damage_player(player)

	players_to_damage = []


func next_team() -> void:
	if active_team != _current_team():
		return

	active_team.next_player(active_player)
	teams.push_back(teams.pop_front())


func get_winner() -> TeamResource:
	if teams.size() > 1:
		push_warning("Winner requested while more than 1 team remaining.")
		return

	return teams[0] if teams.size() == 1 else null


func unlock_item(by: Player, type: PickuppableResource.Type) -> void:
	match type:
		PickuppableResource.Type.WEAPON:
			_unlock_weapon()
		PickuppableResource.Type.TOOL:
			_unlock_tool()
		PickuppableResource.Type.HEALTH:
			_heal_player(by)
		_:
			push_error("Unknown pickuppable type")


func _unlock_random(category_items: Array) -> void:
	var team := _current_team()
	var locked := team.get_locked_items().filter(
		func(item: ItemResource):
			return category_items.has(item),
	)

	if locked.is_empty():
		return

	team.unlock_item(locked.pick_random())


func _unlock_weapon() -> void:
	_unlock_random(GameManager.get_catalogue().weapons)


func _unlock_tool() -> void:
	_unlock_random(GameManager.get_catalogue().tools)


func _heal_player(player_to_heal: Player) -> void:
	player_to_heal.heal()


func _current_team() -> TeamResource:
	return teams.front()


func _get_or_create_team(team_resource: TeamResource) -> TeamResource:
	if teams.has(team_resource):
		return team_resource

	teams.append(team_resource)
	return team_resource


func _kill_player(player: Player) -> void:
	EventSystem.camera.request_follow.emit(player, GameCamera.Priority.HIGH, GameCamera.Zoom.NEAR)
	player.die()
	await player.died
	EventSystem.camera.revoke_follow.emit(player)


func _damage_player(player: Player) -> void:
	EventSystem.camera.request_follow.emit(player, GameCamera.Priority.HIGH, GameCamera.Zoom.NEAR)
	player.apply_damage()
	await player.damage_applied
	EventSystem.camera.revoke_follow.emit(player)


func _on_player_marked_for_death(player: Player) -> void:
	if player == active_player:
		active_player = null

	players_marked_for_death.append(player)

	for team in teams:
		team.kill_player(player)

		if team.has_lost():
			teams.erase(team)
			break


func _on_player_damage_accumulated(player: Player) -> void:
	if players_to_damage.has(player):
		return

	players_to_damage.append(player)


func _on_player_requested_catalogue(player: Player) -> void:
	var locked_items := _current_team().get_locked_items()
	player.open_inventory(locked_items)
