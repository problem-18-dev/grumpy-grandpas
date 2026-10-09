class_name Jetpack
extends Node2D

const PARTICLES_IDLE_MAX_VEL := 16.0
const PARTICLES_FLYING_MAX_VEL := 64.0

@onready var jetpack_particles: CPUParticles2D = $JetpackParticles


func _ready() -> void:
	jetpack_particles.emitting = false
	jetpack_particles.initial_velocity_max = PARTICLES_IDLE_MAX_VEL


func start() -> Jetpack:
	jetpack_particles.emitting = true
	return self


func fly() -> Jetpack:
	jetpack_particles.initial_velocity_max = PARTICLES_FLYING_MAX_VEL
	return self


func idle() -> Jetpack:
	jetpack_particles.initial_velocity_max = PARTICLES_IDLE_MAX_VEL
	return self


func end() -> Jetpack:
	jetpack_particles.emitting = false
	return self
