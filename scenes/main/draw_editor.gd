class_name DrawEditor
extends HSplitContainer

const PREVIEW_TIMEOUT: float = 5.0

enum Tool {
	PENCIL,
	ERASE,
	EYEDROPPER,
	FILL,
	LINE,
	SHAPE,
	SELECT,
}

enum BrushShape {
	SQUARE,
	CIRCLE,
}

var tool := Tool.PENCIL
var brush_shape := BrushShape.SQUARE
var file: FileInstance

var brush_texture: ImageTexture
var small_brush: ImageTexture

var is_drawing: bool = false
var is_hovering: bool = false
var last_point: Vector2i
var last_hover_point: Vector2i

var preview_active: bool = false
var preview_elapsed: float = 0.0

@onready var color_picker: ColorPickerButton = %ColorPicker

@onready var collapse_button: Button = %Collapse

@onready var brush_type_option: PixelOptionButton = %BrushType
@onready var brush_size_slider: VSlider = %BrushSize

@onready var pixel_perfect_button: Button = %PixelPerfect
@onready var continuous_button: Button = %Continuous

@onready var mirror_options_box: HBoxContainer = %MirrorOptions
@onready var mirror_h_button: Button = %MirrorH
@onready var mirror_v_button: Button = %MirrorV

@onready var tools_box: HBoxContainer = $CanvasPanel/CanvasVBox/ToolsHBox/Tools

@onready var pencil_tool: Button = %Pencil
@onready var erase_tool: Button = %Erase
@onready var eyedropper_tool: Button = %Eyedropper
@onready var fill_tool: Button = %Fill
@onready var line_tool: Button = %Line
@onready var shape_tool: Button = %Shape
@onready var select_tool: Button = %Select

@onready var draw_canvas: DrawCanvas = %DrawCanvas


func _ready() -> void:
	update_tool_options()

	_connect_signals()
	_create_small_brush()


func _process(delta: float) -> void:
	if not preview_active:
		return

	preview_elapsed += delta

	if preview_elapsed > PREVIEW_TIMEOUT:
		draw_canvas.clear_preview()
		preview_elapsed = 0.0
		preview_active = false


func update_editor(new_file: FileInstance) -> void:
	file = new_file

	if new_file.mirror_h_enabled:
		mirror_h_button.button_pressed = true

	if new_file.mirror_v_enabled:
		mirror_v_button.button_pressed = true

	draw_canvas.refresh_layers(new_file)


func set_tool(new_tool: Tool) -> void:
	tool = new_tool
	update_tool_options()


func update_tool_options() -> void:
	brush_type_option.hide()
	brush_size_slider.hide()
	pixel_perfect_button.hide()
	continuous_button.hide()
	mirror_options_box.hide()

	match tool:
		Tool.PENCIL, Tool.ERASE:
			brush_type_option.show()
			brush_size_slider.show()
			pixel_perfect_button.show()
			mirror_options_box.show()
		Tool.FILL:
			continuous_button.show()
			mirror_options_box.show()
		Tool.LINE, Tool.SHAPE:
			brush_type_option.show()
			brush_size_slider.show()
			mirror_options_box.show()
		Tool.SELECT:
			mirror_options_box.show()


func update_brush_texture() -> void:
	var brush_size := int(brush_size_slider.value)

	match brush_shape:
		BrushShape.SQUARE:
			var image := Image.create_empty(brush_size, brush_size, false, Image.FORMAT_RGBA8)
			image.fill(Color.WHITE)

			brush_texture = ImageTexture.create_from_image(image)

		BrushShape.CIRCLE:
			var image := Image.create_empty(brush_size, brush_size, false, Image.FORMAT_RGBA8)
			image.fill(Color.TRANSPARENT)

			var center := Vector2(brush_size, brush_size) / 2.0
			var radius: float = brush_size / 2.0

			for y: int in brush_size:
				for x: int in brush_size:
					var point := Vector2(x + 0.5, y + 0.5)

					if Geometry2D.is_point_in_circle(point, center, radius):
						image.set_pixel(x, y, Color.WHITE)

			brush_texture = ImageTexture.create_from_image(image)


func event_pressed(color: Color, point: Vector2i) -> void:
	_stop_preview()

	match tool:
		Tool.PENCIL, Tool.ERASE:
			last_point = point

			draw_canvas.paint_stamp(
				brush_texture,
				file.current_layer.texture,
				color if not tool == Tool.ERASE else Color.TRANSPARENT,
				last_point,
			)

		Tool.EYEDROPPER:
			var image: Image = file.current_layer.texture.get_image()
			var pixel_color: Color = image.get_pixelv(point)

			color_picker.color = pixel_color

			pencil_tool.button_pressed = true
			pencil_tool.pressed.emit()


func event_released(color: Color, point: Vector2i) -> void:
	_stop_preview()


func event_hover_motion(color: Color, point: Vector2i) -> void:
	if is_drawing:
		return

	preview_active = true
	preview_elapsed = 0.0

	match tool:
		Tool.EYEDROPPER, Tool.FILL, Tool.SELECT:
			draw_canvas.preview_stamp(
				small_brush,
				color if not tool == Tool.EYEDROPPER else Color.TRANSPARENT,
				point,
			)
		_:
			draw_canvas.preview_stamp(
				brush_texture,
				color if not tool == Tool.ERASE else Color.TRANSPARENT,
				point,
			)


func event_pressed_motion(color: Color, point: Vector2i) -> void:
	match tool:
		Tool.PENCIL, Tool.ERASE:
			draw_canvas.paint_stroke(
				brush_texture,
				file.current_layer.texture,
				color,
				last_point,
				point,
			)

			last_point = point


func _connect_signals() -> void:
	pencil_tool.pressed.connect(set_tool.bind(Tool.PENCIL))
	erase_tool.pressed.connect(set_tool.bind(Tool.ERASE))
	eyedropper_tool.pressed.connect(set_tool.bind(Tool.EYEDROPPER))
	fill_tool.pressed.connect(set_tool.bind(Tool.FILL))
	line_tool.pressed.connect(set_tool.bind(Tool.LINE))
	shape_tool.pressed.connect(set_tool.bind(Tool.SHAPE))
	select_tool.pressed.connect(set_tool.bind(Tool.SELECT))

	brush_type_option.item_selected.connect(
		func(index: int) -> void:
			match index:
				0:
					brush_shape = BrushShape.SQUARE
				1:
					brush_shape = BrushShape.CIRCLE

			update_brush_texture(),
	)

	brush_size_slider.value_changed.connect(update_brush_texture.unbind(1))


func _create_small_brush() -> void:
	var image := Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)

	small_brush = ImageTexture.create_from_image(image)


func _stop_preview() -> void:
	if not preview_active:
		return

	draw_canvas.clear_preview()
	preview_active = false


func _get_canvas_mouse_pos() -> Vector2i:
	return Vector2i(draw_canvas.get_local_mouse_position())


func _on_canvas_gui_input(event: InputEvent) -> void:
	if event.device < 1:
		return

	if brush_texture == null:
		update_brush_texture()

	var color: Color = color_picker.color
	var point: Vector2i = _get_canvas_mouse_pos()

	if event is InputEventMouseButton:
		if not event.button_index == MOUSE_BUTTON_LEFT:
			return

		if event.is_pressed():
			is_drawing = true
			event_pressed(color, point)

		elif event.is_released():
			is_drawing = false
			event_released(color, point)

	if event is InputEventMouseMotion:
		if point == last_hover_point:
			return

		last_hover_point = point
		is_hovering = true

		if is_drawing:
			event_pressed_motion(color, point)
		else:
			event_hover_motion(color, point)
	else:
		is_hovering = false
