class_name Player
extends CharacterBody2D

signal died(player: Player)

const WEAPONS_CATALOGUE = preload("uid://b4umg781jsip2")
const DEFAULT_WEAPON := WEAPONS_CATALOGUE.default_weapon
const LEFT_DIRECTION := -1
const RIGHT_DIRECTION := 1
const FLOOR_MAX_ANGLE := 80

var _equipped_weapon: WeaponResource = DEFAULT_WEAPON
var _last_direction := RIGHT_DIRECTION

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var weapon_holder: WeaponHolder = $WeaponHolder
@onready var state_machine: StateMachine = $StateMachine
@onready var player_hud: PlayerHUD = $PlayerHUD
@onready var name_label: Label = $NameLabel


func _ready() -> void:
	toggle_inventory()


func _physics_process(_delta: float) -> void:
	_flip_sprite()

#region Weapons
func equip_weapon(weapon_resource: WeaponResource) -> void:
	weapon_holder.equip_weapon(weapon_resource, _last_direction)


func unequip_weapon() -> void:
	weapon_holder.remove_weapon()


func reequip_weapon() -> void:
	equip_weapon(_equipped_weapon)
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


func spawn(spawn_position: Vector2, floor_normal: Vector2) -> void:
	var shape: CapsuleShape2D = collision_shape_2d.shape
	var floor_offset := spawn_position + (floor_normal * shape.radius)
	global_position = floor_offset + (Vector2.UP * (shape.height / 2 - shape.radius))


func setup(team: TeamResource, player: PlayerResource) -> void:
	name_label.add_theme_color_override("font_color", team.color)
	name_label.text = player.name
#endregion

func toggle_inventory() -> void:
	if player_hud.visible:
		player_hud.close()
		return

	player_hud.open(_equipped_weapon)


func _flip_sprite() -> void:
	if is_zero_approx(velocity.x):
		return

	sprite.flip_h = velocity.x < 0


func _on_player_hud_weapon_selected(equipped_weapon: WeaponResource) -> void:
	_equipped_weapon = equipped_weapon


func _on_hurtbox_component_knockbacked(force: float, angle: float) -> void:
	state_machine.transition_to_state(PlayerState.KNOCKBACK, { "force": force, "angle": angle })


func _on_hurtbox_component_hurt(_amount: int) -> void:
	EventSystem.business.busy_started.emit(self)


# TODO: Implement special death state
func _on_health_component_died() -> void:
	died.emit(self)
	EventSystem.business.busy_finished.emit(self)
	EventSystem.camera.revoke_follow.emit(self)
	queue_free()


func _on_weapon_holder_fired() -> void:
	deactivate()
