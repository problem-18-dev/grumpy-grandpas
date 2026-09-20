extends TutorialState

@onready var busy_manager: BusyManager = %BusyManager
@onready var players_manager: PlayersManager = %PlayersManager


func _start() -> void:
	super()
	InputGate.allow_some(["move_left", "move_right", "jump", "up", "down", "camera", "shoot"])

	if not busy_manager.busy_ended.is_connected(_on_busy_manager_busy_ended):
		busy_manager.busy_ended.connect(_on_busy_manager_busy_ended, CONNECT_ONE_SHOT)

	if not players_manager.player_drowned.is_connected(_on_player_drowned):
		players_manager.player_drowned.connect(_on_player_drowned, CONNECT_ONE_SHOT)


func _on_busy_manager_busy_ended() -> void:
	await tutorial.players_manager.damage_players()
	_next_phase()


func _on_player_drowned(player: Player) -> void:
	if player.team.get_id() != tutorial.TEAM_TUTORIAL_RED.get_id():
		return

	_next_phase()
