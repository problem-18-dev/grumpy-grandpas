class_name Player
extends CharacterBody2D

signal marked_for_death(player: Player)
signal died(player: Player)

const WEAPONS_CATALOGUE = preload("uid://b4umg781jsip2")
const DEFAULT_WEAPON := WEAPONS_CATALOGUE.default_weapon
const LEFT_DIRECTION := -1
const RIGHT_DIRECTION := 1
const FLOOR_MAX_ANGLE := 80

var _equipped_aimable: AimableResource = DEFAULT_WEAPON
var _last_direction := RIGHT_DIRECTION

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var aimable_holder: AimableHolder = $AimableHolder
@onready var state_machine: StateMachine = $StateMachine
@onready var player_hud: PlayerHUD = $PlayerHUD
@onready var name_label: Label = $NameLabel
@onready var hurtbox: HurtboxComponent = $HurtboxComponent


func _ready() -> void:
	toggle_inventory()


func _physics_process(_delta: float) -> void:
	_flip_sprite()

#region Aimables
func equip_aimable(aimable_resource: AimableResource) -> void:
	aimable_holder.equip_aimable(aimable_resource, _last_direction)


func unequip_aimable() -> void:
	aimable_holder.remove_aimable()


func reequip_aimable() -> void:
	equip_aimable(_equipped_aimable)
#endregion

#region Direction
func get_direction() -> float:
	return Input.get_axis("move_left", "move_right")


func register_last_direction(new_last_direction: float) -> void:
	_last_direction = LEFT_DIRECTION if new_last_direction < 0 else RIGHT_DIRECTION
#endregion

#region Control
func activate() -> void:
	state_machine.transition_to_state(PlayerState.IDLE)


func deactivate() -> void:
	state_machine.transition_to_state(PlayerState.INACTIVE)


func die() -> void:
	state_machine.transition_to_state(PlayerState.DEAD)


func spawn(spawn_position: Vector2, floor_normal: Vector2) -> void:
	var shape: CapsuleShape2D = collision_shape_2d.shape
	var floor_offset := spawn_position + (floor_normal * shape.radius)
	global_position = floor_offset + (Vector2.UP * (shape.height / 2 - shape.radius))


func setup(team: TeamResource, player: PlayerResource) -> void:
	name_label.add_theme_color_override("font_color", team.color)
	name_label.text = player.name
	name = player.name
#endregion

func toggle_inventory() -> void:
	if player_hud.visible:
		player_hud.close()
		return

	player_hud.open(_equipped_aimable)


func _flip_sprite() -> void:
	if is_zero_approx(velocity.x):
		return

	sprite.flip_h = velocity.x < 0


func _on_hurtbox_component_knockbacked(force: float, angle: float) -> void:
	state_machine.transition_to_state(PlayerState.KNOCKBACK, { "force": force, "angle": angle })


func _on_aimable_holder_fired(ends_turn: bool, player_state: String, state_data: Dictionary) -> void:
	if ends_turn:
		deactivate()
		return

	if player_state:
		state_machine.transition_to_state(player_state, state_data)
		return


func _on_health_component_died() -> void:
	marked_for_death.emit(self)


func _on_player_hud_aimable_selected(aimable: AimableResource) -> void:
	_equipped_aimable = aimable
	reequip_aimable()
