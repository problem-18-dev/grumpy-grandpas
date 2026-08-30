class_name Player
extends CharacterBody2D

signal marked_for_death(player: Player)
signal requested_catalogue(player: Player)
signal damage_accumulated(player: Player)
signal damage_applied
signal died
signal finished

const CATALOGUE = preload("uid://gr6x0tlr2xog")
const LEFT_DIRECTION := -1
const RIGHT_DIRECTION := 1
const FLOOR_MAX_ANGLE := 80

var _equipped_item: ItemResource = CATALOGUE.default_weapon
var _inventory_locked := false
var _ammo_remaining := 0
var _damage_accumulated := 0
var _last_direction := RIGHT_DIRECTION

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var aimable_holder: AimableHolder = $AimableHolder
@onready var state_machine: StateMachine = $StateMachine
@onready var player_hud: PlayerHUD = $PlayerHUD
@onready var name_label: Label = $NameLabel
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var health: HealthComponent = $HealthComponent
@onready var damage_indicator: DamageIndicator = $DamageIndicator


func _ready() -> void:
	player_hud.close()
	_set_ammo(CATALOGUE.default_weapon.aimable_resource.ammo)


func _physics_process(_delta: float) -> void:
	_flip_sprite()

#region Aimables
func equip_aimable(aimable_resource: AimableResource) -> void:
	aimable_holder.equip_aimable(aimable_resource, _last_direction)


func unequip_aimable() -> void:
	aimable_holder.remove_aimable()


func reequip_aimable() -> void:
	equip_aimable(_equipped_item.aimable_resource)
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

#region Inventory
func toggle_inventory() -> void:
	if player_hud.visible or _inventory_locked:
		player_hud.close()
		return

	requested_catalogue.emit(self)


func open_inventory(locked_items: Array[ItemResource]) -> void:
	player_hud.open(locked_items, _equipped_item)
#endregion

#region Damage & Healing

func heal(amount := 25) -> void:
	health.add_health(amount)


func apply_damage() -> void:
	if _damage_accumulated <= 0:
		return

	health.take_health(_damage_accumulated)
#endregion

func _reset() -> void:
	_ammo_remaining = 0
	_damage_accumulated = 0
	_inventory_locked = false


func _flip_sprite() -> void:
	if is_zero_approx(velocity.x):
		return

	sprite.flip_h = velocity.x < 0


func _set_ammo(amount: int) -> void:
	_ammo_remaining = amount


func _on_hurtbox_component_knockbacked(force: float, angle: float) -> void:
	state_machine.transition_to_state(PlayerState.KNOCKBACK, { "force": force, "angle": angle })


func _on_hurtbox_component_hurt(amount: int) -> void:
	_damage_accumulated += amount
	damage_accumulated.emit(self)


func _on_health_component_health_added(amount: int) -> void:
	damage_indicator.display(amount)


func _on_health_component_health_taken(amount: int) -> void:
	damage_indicator.display(-amount)


func _on_health_component_died() -> void:
	marked_for_death.emit(self)


func _on_player_hud_item_selected(item: ItemResource) -> void:
	_equipped_item = item

	var new_player_state := PlayerState.IDLE

	if item.aimable_resource:
		reequip_aimable()
		_set_ammo(item.aimable_resource.ammo)

	if item.set_player_state_on_equip:
		new_player_state = item.player_state

	state_machine.transition_to_state(new_player_state)


func _on_aimable_holder_aimable_used(player_state: String, state_data: Dictionary) -> void:
	state_machine.transition_to_state(player_state, state_data)


# TODO: Weapon holder being busy would work better here, more control over firing collisions
func _on_aimable_holder_aimable_fired() -> void:
	_ammo_remaining -= 1
	Debug.log("Ammo remaining: %s" % _ammo_remaining)

	if _ammo_remaining > 0:
		EventSystem.busy.busy_started.emit(self)
		_inventory_locked = true
		return

	_reset()
	deactivate()
	finished.emit()
	EventSystem.busy.busy_finished.emit(self)


func _on_damage_indicator_finished() -> void:
	damage_applied.emit(self)
