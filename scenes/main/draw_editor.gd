class_name DrawEditor
extends HSplitContainer

enum Tool {
	DRAW,
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

var tool := Tool.DRAW
var brush_shape := BrushShape.SQUARE
var file: FileInstance
var brush_texture: ImageTexture

var is_drawing: bool = false
var last_point: Vector2i

@onready var color_picker: ColorPickerButton = %ColorPicker

@onready var collapse_button: Button = %Collapse

@onready var brush_options_box: HBoxContainer = %BrushOptions
@onready var brush_type_option: PixelOptionButton = %BrushType
@onready var brush_size_box: SpinBox = %BrushSize

@onready var pixel_perfect_button: Button = %PixelPerfect
@onready var continuous_button: Button = %Continuous

@onready var mirror_options_box: HBoxContainer = %MirrorOptions
@onready var mirror_h_button: Button = %MirrorH
@onready var mirror_v_button: Button = %MirrorV

@onready var tools_box: HBoxContainer = $CanvasPanel/CanvasVBox/ToolsHBox/Tools

@onready var draw_tool: Button = %Draw
@onready var erase_tool: Button = %Erase
@onready var eyedropper_tool: Button = %Eyedropper
@onready var fill_tool: Button = %Fill
@onready var line_tool: Button = %Line
@onready var shape_tool: Button = %Shape
@onready var select_tool: Button = %Select

@onready var draw_canvas: DrawCanvas = %DrawCanvas


func _ready() -> void:
	_connect_signals()


func update_editor(new_file: FileInstance) -> void:
	file = new_file

	if new_file.mirror_h_enabled:
		mirror_h_button.button_pressed = true

	if new_file.mirror_v_enabled:
		mirror_v_button.button_pressed = true

	draw_canvas.refresh_layers(new_file)


func set_tool(toggled_on: bool, new_tool: Tool) -> void:
	if not toggled_on:
		return

	tool = new_tool


func update_brush_texture() -> void:
	var brush_size := int(brush_size_box.value)

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


func draw_input(event: InputEventMouse, erase: bool) -> void:
	var color: Color = color_picker.color if not erase else Color.TRANSPARENT

	if event is InputEventMouseButton:
		if not event.button_index == MOUSE_BUTTON_LEFT:
			return

		if not event.is_pressed():
			is_drawing = false
			return

		is_drawing = true

		if brush_texture == null:
			update_brush_texture()

		last_point = _get_canvas_mouse_pos()

		draw_canvas.paint_line(
			brush_texture,
			file.current_layer.texture,
			color,
			last_point,
			last_point,
		)

	if event is InputEventMouseMotion and is_drawing:
		var current_point: Vector2i = _get_canvas_mouse_pos()

		draw_canvas.paint_line(
			brush_texture,
			file.current_layer.texture,
			color,
			last_point,
			current_point,
		)

		last_point = current_point


func _connect_signals() -> void:
	draw_tool.toggled.connect(set_tool.bind(Tool.DRAW))
	erase_tool.toggled.connect(set_tool.bind(Tool.ERASE))
	eyedropper_tool.toggled.connect(set_tool.bind(Tool.EYEDROPPER))
	fill_tool.toggled.connect(set_tool.bind(Tool.FILL))
	line_tool.toggled.connect(set_tool.bind(Tool.LINE))
	shape_tool.toggled.connect(set_tool.bind(Tool.SHAPE))
	select_tool.toggled.connect(set_tool.bind(Tool.SELECT))

	brush_type_option.item_selected.connect(
		func(index: int) -> void:
			match index:
				0:
					brush_shape = BrushShape.SQUARE
				1:
					brush_shape = BrushShape.CIRCLE

			update_brush_texture(),
	)

	brush_size_box.value_changed.connect(update_brush_texture.unbind(1))


func _get_canvas_mouse_pos() -> Vector2i:
	return Vector2i(draw_canvas.input_layer.get_local_mouse_position())


func _on_canvas_gui_input(event: InputEvent) -> void:
	match tool:
		Tool.DRAW, Tool.ERASE:
			if not event is InputEventMouse:
				return

			draw_input(event, tool == Tool.ERASE)
