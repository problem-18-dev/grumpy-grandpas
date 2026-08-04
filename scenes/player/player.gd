class_name Player
extends CharacterBody2D

const WEAPONS_CATALOGUE = preload("uid://b4umg781jsip2")
const LEFT_DIRECTION := -1
const RIGHT_DIRECTION := 1
const DEFAULT_WEAPON := WEAPONS_CATALOGUE.default_weapon

var _equipped_weapon: WeaponResource = DEFAULT_WEAPON
var _last_direction := RIGHT_DIRECTION

@onready var weapon_holder: WeaponHolder = $WeaponHolder
@onready var sprite: Sprite2D = $Sprite2D
@onready var player_hud: PlayerHUD = $PlayerHUD
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	player_hud.close()


func _physics_process(_delta: float) -> void:
	_flip_sprite()


func equip_weapon(weapon_resource: WeaponResource) -> void:
	weapon_holder.equip_weapon(weapon_resource, _last_direction)


func unequip_weapon() -> void:
	weapon_holder.remove_weapon()


func reequip_weapon() -> void:
	equip_weapon(_equipped_weapon)


func get_direction() -> float:
	return Input.get_axis("move_left", "move_right")


func register_last_direction(new_last_direction: float) -> void:
	_last_direction = LEFT_DIRECTION if new_last_direction < 0 else RIGHT_DIRECTION


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

	#TODO: Player shouldn't be able to equip weapon while moving
	reequip_weapon()


func _on_hurtbox_component_knockbacked(force: float, angle: float) -> void:
	state_machine.transition_to_state(PlayerState.KNOCKBACK, { "force": force, "angle": angle })
