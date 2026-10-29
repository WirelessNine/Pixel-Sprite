class_name DrawCanvas
extends CenterContainer

var layers: Array[TextureRect]

@onready var input_layer: Control = $InputLayer
@onready var preview_layer: TextureRect = $PreviewLayer

var preview_texture: DrawableTexture2D


func _ready() -> void:
	preview_texture = DrawableTexture2D.new()
	preview_layer.texture = preview_texture


func refresh_layers(file: FileInstance) -> void:
	for x: TextureRect in layers:
		layers.erase(x)
		x.queue_free()

	input_layer.custom_maximum_size = file.canvas_size
	preview_texture.setup(
		file.canvas_size.x,
		file.canvas_size.y,
		DrawableTexture2D.DRAWABLE_FORMAT_RGBA8,
		Color.TRANSPARENT,
	)

	var selected_layer: TextureRect

	for x: FileInstance.Layer in file.layers:
		var rect: TextureRect = _create_layer(x.texture)
		rect.name = x.name

		if file.current_layer == x:
			selected_layer = rect

	move_child(preview_layer, selected_layer.get_index())


func _create_layer(texture: DrawableTexture2D) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture

	layers.append(rect)
	add_child(rect)

	return rect
