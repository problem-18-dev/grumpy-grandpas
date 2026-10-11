extends Node

var camera: Camera = Camera.new()


class Camera:
	signal request_follow(target: Node2D, priority: GameCamera.Priority, zoom: GameCamera.Zoom)
	signal revoke_follow(target: Node2D)
	signal shake(noise: PhantomCameraNoise2D, duration: float)
	signal request_manual(manual_position: Vector2)
	signal revoke_manual
