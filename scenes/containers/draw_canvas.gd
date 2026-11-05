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


func paint_circle(
	brush: Texture2D,
	layer_texture: DrawableTexture2D,
	color: Color,
	start: Vector2i,
	end: Vector2i,
	filled: bool,
) -> void:
	var points: Array[Vector2i] = []

	var x0: int = min(start.x, end.x)
	var x1: int = max(start.x, end.x)
	var y0: int = min(start.y, end.y)
	var y1: int = max(start.y, end.y)

	var a: int = x1 - x0
	var b: int = y1 - y0

	if a == 0 and b == 0:
		paint_stamp(brush, layer_texture, color, start)
		return
	if a == 0:
		paint_line(brush, layer_texture, color, Vector2i(x0, y0), Vector2i(x0, y1))
		return
	if b == 0:
		paint_line(brush, layer_texture, color, Vector2i(x0, y0), Vector2i(x1, y0))
		return

	var b1: int = b & 1
	var dx: int = 4 * (1 - a) * b * b
	var dy: int = 4 * (b1 + 1) * a * a
	var err: int = dx + dy + b1 * a * a

	y0 += int((b + 1) / 2.0)
	y1 = y0 - b1

	var sa: int = 8 * a * a
	var sb: int = 8 * b * b

	while x0 <= x1:
		points.append(Vector2i(x1, y0))
		points.append(Vector2i(x0, y0))
		points.append(Vector2i(x0, y1))
		points.append(Vector2i(x1, y1))

		var e2: int = 2 * err

		if e2 <= dy:
			y0 += 1
			y1 -= 1
			dy += sa
			err += dy

		if e2 >= dx or 2 * err > dy:
			x0 += 1
			x1 -= 1
			dx += sb
			err += dx

	while y0 - y1 <= b:
		points.append(Vector2i(x0 - 1, y0))
		points.append(Vector2i(x1 + 1, y0))
		points.append(Vector2i(x0 - 1, y1))
		points.append(Vector2i(x1 + 1, y1))
		y0 += 1
		y1 -= 1

	if filled:
		var rows: Dictionary = { }
		for pt in points:
			if not rows.has(pt.y):
				rows[pt.y] = { "min": pt.x, "max": pt.x }
			else:
				rows[pt.y]["min"] = min(rows[pt.y]["min"], pt.x)
				rows[pt.y]["max"] = max(rows[pt.y]["max"], pt.x)

		for y: int in rows:
			paint_line(
				brush,
				layer_texture,
				color,
				Vector2i(rows[y]["min"], y),
				Vector2i(rows[y]["max"], y),
			)
	else:
		var handled_points: Dictionary = { }
		for pt in points:
			if not handled_points.has(pt):
				handled_points[pt] = true
				paint_stamp(brush, layer_texture, color, pt)


func paint_rectangle(
	brush: Texture2D,
	layer_texture: DrawableTexture2D,
	color: Color,
	start: Vector2i,
	end: Vector2i,
	filled: bool,
) -> void:
	var min_x: int = min(start.x, end.x)
	var max_x: int = max(start.x, end.x)
	var min_y: int = min(start.y, end.y)
	var max_y: int = max(start.y, end.y)

	if filled:
		for y: int in range(min_y, max_y + 1):
			var row_start := Vector2i(min_x, y)
			var row_end := Vector2i(max_x, y)
			paint_line(brush, layer_texture, color, row_start, row_end)
	else:
		var top_left := Vector2i(min_x, min_y)
		var top_right := Vector2i(max_x, min_y)
		var bottom_left := Vector2i(min_x, max_y)
		var bottom_right := Vector2i(max_x, max_y)

		paint_line(brush, layer_texture, color, top_left, top_right)
		paint_line(brush, layer_texture, color, top_right, bottom_right)
		paint_line(brush, layer_texture, color, bottom_right, bottom_left)
		paint_line(brush, layer_texture, color, bottom_left, top_left)


func paint_line(
	brush: Texture2D,
	layer_texture: DrawableTexture2D,
	color: Color,
	start: Vector2i,
	end: Vector2i,
) -> void:
	var line_points: Array[Vector2i] = Geometry2D.bresenham_line(start, end)

	var rect_size: Vector2i = brush.get_size()
	var current_color: Color = color if not color.a == 0.0 else Color(1.0, 0.93, 0.931, 0.392)

	for x: Vector2i in line_points:
		var rect_center: Vector2i = x - Vector2i(rect_size / 2.0)
		var rect := Rect2i(rect_center, rect_size)

		layer_texture.blit_rect(rect, brush, current_color)


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


func preview_circle(brush: Texture2D, color: Color, start: Vector2i, end: Vector2i) -> void:
	clear_preview()

	paint_circle(brush, preview_texture, color, start, end, false)


func preview_rectangle(brush: Texture2D, color: Color, start: Vector2i, end: Vector2i) -> void:
	clear_preview()

	paint_rectangle(brush, preview_texture, color, start, end, false)


func preview_line(brush: Texture2D, color: Color, start: Vector2i, end: Vector2i) -> void:
	clear_preview()

	paint_line(brush, preview_texture, color, start, end)


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
	custom_maximum_size = file.canvas_size

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
