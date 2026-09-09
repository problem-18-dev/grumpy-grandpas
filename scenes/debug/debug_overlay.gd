class_name DebugOverlay
extends Control

const BUILD_VERSION: String = "application/config/version"

@onready var fps_label: Label = %FpsLabel
@onready var build_label: Label = %BuildLabel


func _ready() -> void:
	build_label.text = "Build: %s" % ProjectSettings.get_setting(BUILD_VERSION)


func _process(_delta: float) -> void:
	fps_label.text = "FPS: %s" % Engine.get_frames_per_second()
