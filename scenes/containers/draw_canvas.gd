class_name DrawCanvas
extends CenterContainer

const ERASE_MATERIAL: BlitMaterial = preload("uid://dy8yhdx5od8lf")

var layers: Array[TextureRect]

var preview_texture: DrawableTexture2D

@onready var input_layer: Control = $InputLayer
@onready var background: TextureRect = $Background
@onready var preview_layer: TextureRect = $PreviewLayer


func _ready() -> void:
	preview_texture = DrawableTexture2D.new()
	preview_layer.texture = preview_texture


func paint_line(
	brush: Texture2D,
	texture: DrawableTexture2D,
	color: Color,
	from: Vector2i,
	to: Vector2i,
) -> void:
	var distance: float = from.distance_to(to)

	if distance < 0.1:
		paint_stamp(brush, texture, color, to)
		return

	var steps: int = ceili(distance)

	for x: int in steps + 1:
		var factor := float(x) / float(steps)
		var lerped_point := Vector2i(Vector2(from).lerp(Vector2(to), factor))
		paint_stamp(brush, texture, color, lerped_point)


func paint_stamp(
	brush: Texture2D,
	texture: DrawableTexture2D,
	color: Color,
	point: Vector2i,
) -> void:
	var rect_size: Vector2i = brush.get_size()
	var rect_center: Vector2i = point - Vector2i(rect_size / 2.0)
	var rect := Rect2i(rect_center, rect_size)

	var shader: BlitMaterial = ERASE_MATERIAL if color == Color.TRANSPARENT else null

	texture.blit_rect(rect, brush, color, 0, shader)


func refresh_layers(file: FileInstance) -> void:
	for x: TextureRect in layers:
		layers.erase(x)
		x.queue_free()

	input_layer.custom_minimum_size = file.canvas_size
	background.custom_minimum_size = file.canvas_size
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


func is_cursor_inside(point: Vector2) -> bool:
	return input_layer.get_rect().has_point(point)


func _create_layer(texture: DrawableTexture2D) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture

	layers.append(rect)
	add_child(rect)

	return rect
