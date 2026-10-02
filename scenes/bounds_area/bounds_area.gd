class_name BoundsArea
extends Area2D

signal projectile_exited

var _players: Array[Player] = []
var _projectiles: Array[Projectile] = []


func cleanup_players() -> void:
	for player in _players:
		if is_instance_valid(player):
			player.queue_free()

	_players.clear()


func cleanup_projectiles() -> void:
	for projectile in _projectiles:
		if is_instance_valid(projectile):
			projectile.destroy()

	_projectiles.clear()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_players.append(body)
		return

	if body is Projectile:
		_projectiles.append(body)
		body.cancel()
		projectile_exited.emit()
