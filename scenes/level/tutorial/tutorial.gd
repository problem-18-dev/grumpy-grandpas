class_name Tutorial
extends Node

const HUD_UID := "uid://c5q7bwqmijr3e"
const INVENTORY_UID := "uid://bkrmhl1oip2je"
const MAIN_MENU_UID := "uid://b2d8kklebnhfj"
const TEAM_TUTORIAL_BLUE = preload("uid://cgtof6pv3rtlo")
const TEAM_TUTORIAL_RED = preload("uid://ci6lhhlkv6opp")
const TUTORIAL_LEVEL = preload("uid://bw3v314eg0rgg")
const CRATE = preload("uid://cigipvuxrk2eo")
const TUTORIAL_CATALOGUE = preload("uid://c0onk6kmhoekl")
const KEYCAP = preload("uid://bb8fs5vr1xjp")

@export var initial_phase := TutorialState.Phase.INTRO

var _tutorial_level: TutorialLevel
var _is_preparing := false

@onready var hud: HUD = %HUD
@onready var level_root: Node2D = %LevelRoot
@onready var entity_root: Node2D = %EntityRoot
@onready var keycaps_container: VBoxContainer = %KeycapsContainer
@onready var inventory_root: Control = %InventoryRoot
@onready var continue_label: Label = %ContinueLabel
@onready var busy_manager: BusyManager = %BusyManager
@onready var players_manager: PlayersManager = %PlayersManager
@onready var pickuppable_manager: PickuppableManager = %PickuppableManager
@onready var camera_manager: CameraManager = %CameraManager
@onready var state_machine: StateMachine = %StateMachine


func _ready() -> void:
	await restart()
	state_machine.start(TutorialState.PHASES[initial_phase])


func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return

	if event.is_action_pressed("debug_quit"):
		InputGate.allow_all()
		get_tree().change_scene_to_file(MAIN_MENU_UID)


func restart() -> void:
	if _is_preparing:
		return
	_is_preparing = true

	GameConfigurator.load_preset(GameConfigurator.Preset.TUTORIAL)
	InputGate.block_all()

	_clear_entities()
	await _load_level()
	_load_systems()
	_start()

	_is_preparing = false


func retry_phase() -> void:
	if _is_preparing:
		return

	await restart()
	state_machine.restart_current()


func spawn_pickuppable() -> void:
	pickuppable_manager.spawn(CRATE, _tutorial_level.get_pickuppable_spawn())


func activate_player() -> void:
	if players_manager.active_player:
		return

	players_manager.activate_player()


func show_announcement(text: String) -> void:
	hud.set_message(text)


func create_keycaps(... letters: Array) -> void:
	clear_keycaps()

	for letter: String in letters:
		var keycap: Keycap = KEYCAP.instantiate()
		keycap.text = letter.to_upper()
		keycaps_container.add_child(keycap)
		keycaps_container.show()


func clear_keycaps() -> void:
	keycaps_container.hide()

	for child in keycaps_container.get_children():
		child.queue_free()


func lower_enemy_health() -> void:
	for player: Player in get_tree().get_nodes_in_group("players"):
		if player.team.get_id() != TEAM_TUTORIAL_RED.get_id():
			continue

		player.health.health = 100
		player.health.take_health(99)


func _clear_entities() -> void:
	for child: Node2D in entity_root.get_children():
		child.queue_free()


func _load_level() -> void:
	if _tutorial_level:
		_tutorial_level.queue_free()
		_tutorial_level = null
		await get_tree().process_frame

	var tutorial_level: TutorialLevel = TUTORIAL_LEVEL.instantiate()
	_tutorial_level = tutorial_level
	_tutorial_level.projectile_exited.connect(_on_projectile_exited)
	level_root.add_child(_tutorial_level)


func _load_systems() -> void:
	busy_manager.reset()
	players_manager.reset()
	camera_manager.set_limits(_tutorial_level.get_bounds())


func _start() -> void:
	var blue: TeamResource = TEAM_TUTORIAL_BLUE.duplicate_deep()
	var red: TeamResource = TEAM_TUTORIAL_RED.duplicate_deep()
	players_manager.spawn_player_at(
		blue.player_resources[0],
		blue,
		_tutorial_level.get_player_spawn(),
	)
	players_manager.spawn_player_at(red.player_resources[0], red, _tutorial_level.get_enemy_spawn())


func _on_players_manager_inventory_requested(
	locked_items: Array[ItemResource],
	current_item: ItemResource,
) -> void:
	if busy_manager.is_busy():
		return

	players_manager.deactivate_player()
	var inventory: Inventory = load(INVENTORY_UID).instantiate()
	inventory_root.add_child(inventory)
	inventory.closed.connect(_on_inventory_closed)
	inventory.open(locked_items, current_item)


func _on_players_manager_player_drowned(player: Player) -> void:
	if player.team.get_id() == TEAM_TUTORIAL_BLUE.get_id():
		retry_phase()


func _on_inventory_closed(new_item: ItemResource = null) -> void:
	if initial_phase == TutorialState.Phase.INVENTORY:
		state_machine.transition_to_state(TutorialState.PHASES[TutorialState.Phase.ENEMY_DEATH])

	players_manager.activate_player()

	if new_item:
		players_manager.player_equip(new_item)


func _on_projectile_exited() -> void:
	retry_phase()
