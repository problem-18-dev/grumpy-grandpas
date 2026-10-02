class_name PlayersManager
extends Node

signal inventory_requested(locked_items: Array[ItemResource], current_item: ItemResource)
signal player_died(player: Player)
signal player_drowned(player: Player)
signal player_item_equipped(current_item: ItemResource, player: Player)
signal player_ammo_changed(ammo_remaining: int, current_item: ItemResource, player: Player)

const PLAYER := preload("uid://bmag23mf230r3")

@export_group("Spawn")
@export var spawn_target: Node2D

var teams: Array[TeamResource] = []
var active_team: TeamResource
var active_player: Player
var players_marked_for_death: Array[Player]
var players_to_damage: Array[Player]


func reset() -> void:
	teams = []
	active_team = null
	active_player = null
	players_marked_for_death.clear()
	players_to_damage.clear()


#region Players
func spawn_players(spawn_points: Array[SpawnGenerator.SpawnPoint]) -> void:
	assert(spawn_points.size() > 0, "No spawn points provided.")
	assert(GameManager.get_teams().size() > 0, "No teams to spawn.")

	for team in GameManager.get_teams():
		for player_resource in team.player_resources:
			var spawn_data: SpawnGenerator.SpawnPoint = spawn_points.pop_back()
			spawn_player_at(player_resource, team, spawn_data)


func spawn_player_at(
	player_resource: PlayerResource,
	team: TeamResource,
	spawn_data: SpawnGenerator.SpawnPoint,
) -> void:
	var player: Player = PLAYER.instantiate()
	spawn_target.add_child(player)

	player.spawn(spawn_data.position, spawn_data.normal)
	player.setup(team, player_resource)

	player.marked_for_death.connect(_on_player_marked_for_death)
	player.damage_accumulated.connect(_on_player_damage_accumulated)
	player.inventory_requested.connect(_on_player_inventory_requested)
	player.drowned.connect(_on_player_drowned)
	player.item_equipped.connect(player_item_equipped.emit.bind(player))
	player.ammo_changed.connect(player_ammo_changed.emit.bind(player))
	player.firing_finished.connect(_on_player_firing_finished.bind(player))

	_get_or_create_team(team).add_player(player)


func activate_player() -> Player:
	var player := select_player()
	player.activate()
	return player


func select_player() -> Player:
	deactivate_player()
	active_team = _current_team()
	active_player = active_team.next_player()
	active_player.reset()
	EventSystem.camera.request_follow.emit(active_player, GameCamera.Priority.LOW)
	return active_player


func deactivate_player() -> void:
	if not is_instance_valid(active_player):
		return

	EventSystem.camera.revoke_follow.emit(active_player)
	active_player.deactivate()
	active_player = null


func pause_player() -> void:
	if is_instance_valid(active_player):
		active_player.deactivate()


func resume_player() -> void:
	if is_instance_valid(active_player):
		active_player.activate()


func player_equip(item: ItemResource) -> void:
	active_player.equip_item(item)


func kill_marked_players() -> void:
	while not players_marked_for_death.is_empty():
		var player: Player = players_marked_for_death.pop_front()

		if is_instance_valid(player):
			await _kill_player(player)


func damage_players() -> void:
	while not players_to_damage.is_empty():
		var player: Player = players_to_damage.pop_front()

		if is_instance_valid(player):
			await _damage_player(player)


func has_pending_events() -> bool:
	return not players_to_damage.is_empty() or not players_marked_for_death.is_empty()
#endregion


#region Team
func next_team() -> void:
	if active_team != _current_team():
		return

	teams.push_back(teams.pop_front())


func show_team(team: TeamResource, duration := 0.0) -> void:
	assert(teams.has(team), "Showing team that isn't in the match.")

	var players := team.get_players()
	if players.is_empty():
		return

	var stay := is_zero_approx(duration)
	var per_player := 1.0 if stay else duration / players.size()

	for player in players:
		await _show_player(player, per_player)

	if stay:
		EventSystem.camera.request_follow.emit(
			players[0],
			GameCamera.Priority.HIGH,
			GameCamera.Zoom.NEAR,
		)


func get_winner() -> TeamResource:
	if teams.size() > 1:
		push_warning("Winner requested while more than 1 team remaining.")
		return

	return teams[0] if teams.size() == 1 else null
#endregion


#region Items
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
		func(item: ItemResource) -> bool:
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
#endregion


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
	player_died.emit(player)
	EventSystem.camera.revoke_follow.emit(player)


func _damage_player(player: Player) -> void:
	EventSystem.camera.request_follow.emit(player, GameCamera.Priority.HIGH, GameCamera.Zoom.NEAR)

	if player.apply_damage():
		await player.damage_applied

	EventSystem.camera.revoke_follow.emit(player)


func _show_player(player: Player, duration := 1.0) -> void:
	EventSystem.camera.request_follow.emit(player, GameCamera.Priority.HIGH, GameCamera.Zoom.NEAR)
	await get_tree().create_timer(duration, false).timeout
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


func _on_player_firing_finished(player: Player) -> void:
	# A late finish from a previous player must not deactivate whoever is active now.
	if player == active_player:
		deactivate_player()


func _on_player_damage_accumulated(player: Player) -> void:
	if players_to_damage.has(player):
		return

	players_to_damage.append(player)


func _on_player_drowned(player: Player) -> void:
	players_marked_for_death.erase(player)
	players_to_damage.erase(player)
	player.team.kill_player(player)

	if player.team.has_lost():
		teams.erase(player.team)

		if player.team == active_team:
			active_team = null

	if player == active_player:
		EventSystem.camera.revoke_follow.emit(player)
		active_player = null

	player_drowned.emit(player)


func _on_player_inventory_requested(current_item: ItemResource) -> void:
	var locked_items := active_team.get_locked_items()
	inventory_requested.emit(locked_items, current_item)
