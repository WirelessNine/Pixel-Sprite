class_name DrawCanvas
extends TextureRect

var layers: Array[TextureRect]

var erase_blit: BlitMaterial
var preview_texture: DrawableTexture2D

@onready var preview_layer: TextureRect = $PreviewLayer


func _ready() -> void:
	erase_blit = BlitMaterial.new()
	erase_blit.blend_mode = BlitMaterial.BLEND_MODE_DISABLED

	preview_texture = DrawableTexture2D.new()
	preview_layer.texture = preview_texture


##Paints a continuous stroke, like a pencil or eraser.
func paint_stroke(
	brush: Texture2D,
	layer_texture: DrawableTexture2D,
	color: Color,
	from: Vector2i,
	to: Vector2i,
) -> void:
	var distance: float = from.distance_to(to)

	if distance < 0.1:
		paint_stamp(brush, layer_texture, color, from)
		return

	var steps: int = ceili(distance)

	for x: int in steps + 1:
		var factor := float(x) / float(steps)
		var lerped_point := Vector2i(Vector2(from).lerp(Vector2(to), factor))
		paint_stamp(brush, layer_texture, color, lerped_point)


func paint_stamp(
	brush: Texture2D,
	layer_texture: DrawableTexture2D,
	color: Color,
	point: Vector2i,
) -> void:
	var rect_size: Vector2i = brush.get_size()
	var rect_center: Vector2i = point - Vector2i(rect_size / 2.0)
	var rect := Rect2i(rect_center, rect_size)

	var blit: BlitMaterial = erase_blit if color.a == 0.0 else null

	layer_texture.blit_rect(rect, brush, color, 0, blit)


func preview_stamp(brush: Texture2D, color: Color, point: Vector2i) -> void:
	var rect_size: Vector2i = brush.get_size()
	var rect_center: Vector2i = point - Vector2i(rect_size / 2.0)
	var rect := Rect2i(rect_center, rect_size)

	var current_color: Color = color if not color.a == 0.0 else Color(1.0, 0.93, 0.931, 0.392)

	clear_preview()
	preview_texture.blit_rect(rect, brush, current_color)


func clear_preview() -> void:
	var width: int = preview_texture.get_width()
	var height: int = preview_texture.get_height()

	preview_texture.setup(width, height, DrawableTexture2D.DRAWABLE_FORMAT_RGBA8, Color.TRANSPARENT)


func refresh_layers(file: FileInstance) -> void:
	for x: TextureRect in layers:
		layers.erase(x)
		x.queue_free()

	custom_minimum_size = file.canvas_size

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
	return get_rect().has_point(point)


func _create_layer(layer_texture: DrawableTexture2D) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = layer_texture
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	layers.append(rect)
	add_child(rect)

	rect.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	return rect
