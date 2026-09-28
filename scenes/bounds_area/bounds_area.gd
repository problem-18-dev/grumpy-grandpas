class_name BoundsArea
extends Area2D

signal projectile_exited

var _players: Array[Player] = []
var _projectiles: Array[Projectile] = []


func cleanup_players() -> void:
	_players = _players.filter(_filter_valid)

	for player: Player in _players:
		player.queue_free()

	_players.clear()


func cleanup_projectiles() -> void:
	_projectiles = _projectiles.filter(_filter_valid)

	for projectile: Projectile in _projectiles:
		projectile.destroy()

	_projectiles.clear()


func _filter_valid(instance: Node2D) -> bool:
	return is_instance_valid(instance)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_players.append(body)
		return

	if body is Projectile:
		_projectiles.append(body)
		body.cancel()
		projectile_exited.emit()
