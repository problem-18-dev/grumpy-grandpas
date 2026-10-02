class_name Game
extends Node

enum Level {
	MATCH,
}

const INVENTORY_UID := "uid://bkrmhl1oip2je"
const PAUSE_UID := "uid://c88tu6f6g83br"
const HUD_UID := "uid://c5q7bwqmijr3e"

@export var initial_level := Level.MATCH
@export_group("Intro")
@export var skip_team_intro := false
@export var intro_duration_per_team := 5.0
@export var intro_duration_per_player := 2.5

var _level_paths: Dictionary[Level, String] = { Level.MATCH: "uid://cd2ib37t0cgmf" }
var _current_level: BaseLevel
var _current_inventory: Inventory
var _current_hud: HUD

@onready var level_root: Node2D = %LevelRoot
@onready var inventory_root: Control = %InventoryRoot
@onready var hud_root: Control = %HUDRoot
@onready var pause_root: Control = %PauseRoot

@onready var busy_manager: BusyManager = %BusyManager
@onready var turn_manager: TurnManager = %TurnManager
@onready var players_manager: PlayersManager = %PlayersManager
@onready var pickuppable_manager: PickuppableManager = %PickuppableManager
@onready var camera_manager: CameraManager = %CameraManager


func _ready() -> void:
	if not OS.is_debug_build():
		skip_team_intro = false

	await load_level(initial_level)
	load_hud()
	_start_level()


func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or get_tree().paused:
		return

	if event.is_action_pressed(&"quit"):
		_pause()

	if event.is_action_pressed("debug_quit"):
		SceneLoader.load_scene(SceneLoader.Scenes.MENU)


func load_level(new_scene: Level) -> void:
	if _current_level:
		_current_level.queue_free()
		_current_level = null
		await get_tree().process_frame

	_current_level = load(_level_paths[new_scene]).instantiate()
	_current_level.projectile_exited.connect(_on_projectile_exited)
	level_root.add_child(_current_level)

	await get_tree().process_frame

	load_systems()


func load_hud() -> void:
	_current_hud = load(HUD_UID).instantiate()
	hud_root.add_child(_current_hud)


func load_systems() -> void:
	busy_manager.reset()
	turn_manager.reset()
	players_manager.reset()
	pickuppable_manager.setup(_current_level.get_spawn_follow())
	camera_manager.set_limits(_current_level.get_bounds())


func _start_level() -> void:
	var spawn_points := _current_level.get_spawn_points()
	players_manager.spawn_players(spawn_points)
	await _introduce_teams()

	var new_player := players_manager.activate_player()
	_update_hud(new_player)
	_current_hud.set_message(
		"Time for %s!" % new_player.player_name,
		intro_duration_per_player,
		players_manager.active_team.get_color(),
	)
	turn_manager.start_turn()


func _announce_winner() -> void:
	var winner := players_manager.get_winner()

	if winner:
		players_manager.show_team(winner)
		_current_hud.set_message("%s has won!" % winner.name)
		return

	_current_hud.set_message("No winners this time!")


func _introduce_teams() -> void:
	if skip_team_intro:
		return

	for team in players_manager.teams:
		_current_hud.set_message("Introducing Team %s" % team.name, 0.0, team.get_color())
		await players_manager.show_team(team, intro_duration_per_team)

	_current_hud.set_message("")


func _pause() -> void:
	get_tree().paused = true

	var pause: PauseOverlay = load(PAUSE_UID).instantiate()
	pause_root.add_child(pause)


func _continue() -> void:
	if players_manager.teams.size() <= 1:
		_announce_winner()
		return

	busy_manager.reset()
	await pickuppable_manager.attempt_spawn()
	players_manager.next_team()
	var new_player := players_manager.activate_player()
	_update_hud(new_player)
	_current_hud.set_message("Time for %s!" % new_player.name, 3.0)
	turn_manager.start_turn()


func _update_hud(player: Player) -> void:
	assert(_current_hud, "Updating HUD but no HUD available.")

	_current_hud.set_item(player.equipped_item)
	_current_hud.show_camera_shortcut()


func _on_pickuppable_manager_picked_up(by: Player, type: PickuppableResource.Type) -> void:
	players_manager.unlock_item(by, type)


func _on_busy_manager_busy_started() -> void:
	print("Busy started")
	turn_manager.hold_turn()


func _on_busy_manager_busy_ended() -> void:
	print("Busy ended")
	turn_manager.finish_turn()


func _on_turn_manager_time_changed(time: int, is_urgent: bool) -> void:
	_current_hud.set_turn_timer(time, is_urgent)


func _on_turn_manager_transition_finished() -> void:
	_current_level.bounds.cleanup_projectiles()
	await players_manager.damage_players()
	await players_manager.kill_marked_players()
	_current_level.bounds.cleanup_players()
	_continue()


func _on_turn_manager_turn_ended() -> void:
	players_manager.deactivate_player()

	if _current_inventory:
		_current_inventory.queue_free()
		_current_inventory = null


func _on_players_manager_inventory_requested(
	locked_items: Array[ItemResource],
	current_item: ItemResource,
) -> void:
	if busy_manager.is_busy():
		return

	players_manager.pause_player()
	_current_inventory = load(INVENTORY_UID).instantiate()
	inventory_root.add_child(_current_inventory)
	_current_inventory.closed.connect(_on_inventory_closed)
	_current_inventory.open(locked_items, current_item)


func _on_inventory_closed(new_item: ItemResource = null) -> void:
	_current_inventory = null
	players_manager.resume_player()

	if not new_item:
		return

	players_manager.player_equip(new_item)


func _on_projectile_exited() -> void:
	turn_manager.finish_turn()


func _on_players_manager_player_ammo_changed(
	ammo_remaining: int,
	current_item: ItemResource,
	_player: Player,
) -> void:
	if not _current_hud:
		push_warning("Player ammo change HUD adjustment, but no current hud.")
		return

	_current_hud.set_item_ammo(ammo_remaining, current_item.aimable_resource.ammo)


func _on_players_manager_player_item_equipped(_current_item: ItemResource, player: Player) -> void:
	_update_hud(player)
