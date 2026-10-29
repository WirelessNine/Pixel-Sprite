class_name FileInstance
extends RefCounted

var file_path: String = ""
var title: String
var canvas_size: Vector2i

var palette: ColorPalette

var mirror_h_enabled: bool = false
var mirror_h_pos: int

var mirror_v_enabled: bool = false
var mirror_v_pos: int

var current_layer: Layer
var layers: Array[Layer]


func setup_file() -> void:
	if not canvas_size > Vector2i.ZERO:
		push_error("Canvas size must be larger than 0.")
		return

	add_layer("Layer")


func add_layer(name: String) -> void:
	var texture := DrawableTexture2D.new()
	texture.setup(
		canvas_size.x,
		canvas_size.y,
		DrawableTexture2D.DRAWABLE_FORMAT_RGBA8,
		Color.TRANSPARENT,
	)

	var layer: Layer = _create_layer(name, texture)
	set_current_layer(layer)


func set_current_layer(layer: Layer) -> void:
	if layer == null:
		push_error("Current layer can't be null.")
		return

	current_layer = layer


func _create_layer(name: String, texture: DrawableTexture2D) -> Layer:
	var layer := Layer.new()
	layer.name = name
	layer.texture = texture

	layers.append(layer)

	return layer


class Layer:
	var name: String
	var texture: DrawableTexture2D
