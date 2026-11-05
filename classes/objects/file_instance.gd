class_name FileInstance
extends Resource

@export var file_path: String = ""
@export var canvas_size: Vector2i
@export var layers: Array[Layer]

var title: String

var palette: ColorPalette

var mirror_h_enabled: bool = false
var mirror_h_pos: int

var mirror_v_enabled: bool = false
var mirror_v_pos: int

var current_layer: Layer


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


func get_as_image() -> Image:
	var image := Image.create_empty(canvas_size.x, canvas_size.y, false, Image.FORMAT_ETC2_RGBA8)

	if image.is_compressed():
		image.decompress()

	image.fill(Color(1.0, 1.0, 1.0, 0.0))

	for x: Layer in layers:
		var layer_image: Image = x.texture.get_image()

		image.blend_rect(layer_image, Rect2i(Vector2i.ZERO, canvas_size), Vector2i.ZERO)

	return image


func _create_layer(name: String, texture: DrawableTexture2D) -> Layer:
	var layer := Layer.new()
	layer.name = name
	layer.texture = texture

	layers.append(layer)

	return layer
