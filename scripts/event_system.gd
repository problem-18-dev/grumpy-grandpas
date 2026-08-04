extends Node

var projectiles := Projectiles.new()


class Projectiles:
	signal projectile_fired(projectile: Projectile)
