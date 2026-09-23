@tool
class_name BandedLabel
extends Label

# Top of the text is 0.0, bottom is 1.0. One stop per color: the stop is where
# that color ends, so spans are just the gaps between stops.
const DEFAULT_BAND_COLORS := PackedColorArray([
	Color(0.99, 0.87, 0.25),
	Color(0.98, 0.98, 0.96),
	Color(0.95, 0.55, 0.13),
])
const DEFAULT_BAND_STOPS := PackedFloat32Array([0.55, 0.65, 1.0])

const BANDED_TEXT_SHADER := preload("res://gui/shaders/banded_text.gdshader")

const BAND_COLORS := &"band_colors"
const BAND_STOPS := &"band_stops"
const BAND_COUNT := &"band_count"
const TEXT_HEIGHT := &"text_height"

@export var band_colors := DEFAULT_BAND_COLORS:
	set(value):
		band_colors = value
		_apply_bands()

@export var band_stops := DEFAULT_BAND_STOPS:
	set(value):
		band_stops = value
		_apply_bands()

@export var band_offset := 0.0:
	set(value):
		band_offset = value
		_set_parameter(&"band_offset", value)

@export var band_scale := 1.0:
	set(value):
		band_scale = value
		_set_parameter(&"band_scale", value)


func _ready() -> void:
	if material == null:
		var banded_material := ShaderMaterial.new()
		banded_material.shader = BANDED_TEXT_SHADER
		material = banded_material

	resized.connect(_sync_text_height)
	_sync_text_height()
	_apply_bands()


# Runtime palette, e.g. team colors.
func set_bands(colors: PackedColorArray, stops: PackedFloat32Array) -> void:
	band_colors = colors
	band_stops = stops


func _apply_bands() -> void:
	if not is_node_ready():
		return

	var stops := band_stops
	while stops.size() < band_colors.size():
		stops.append(1.0)

	_set_parameter(BAND_COLORS, band_colors.slice(0, 8))
	_set_parameter(BAND_STOPS, stops.slice(0, 8))
	_set_parameter(BAND_COUNT, mini(band_colors.size(), 8))


func _sync_text_height() -> void:
	_set_parameter(TEXT_HEIGHT, size.y)


func _set_parameter(parameter: StringName, value: Variant) -> void:
	var banded_material := material as ShaderMaterial
	if banded_material == null:
		return

	banded_material.set_shader_parameter(parameter, value)
