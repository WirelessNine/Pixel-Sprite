extends ColorRect

const ZOOM_FACTOR: float = 1.12
const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 20.0
const DOUBLE_CLICK_TIMEOUT: float = 350.0

var zoom: float = 1.0

var pan := Vector2.ZERO
var dragging: bool = false
var drag_start := Vector2.ZERO
var pan_start := Vector2.ZERO

var has_screen_touched: bool = false

@onready var canvas: DrawCanvas = %DrawCanvas


func _ready() -> void:
	_reset_canvas()
	_update_texture()


func _gui_input(event: InputEvent) -> void:
	if OS.has_feature("mobile"):
		_mobile_input(event)
	else:
		_desktop_input(event)


func _mobile_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		has_screen_touched = false
	elif event is InputEventScreenTouch:
		has_screen_touched = true

	if event is InputEventMagnifyGesture and has_screen_touched:
		_zoom_at(event.position, event.factor)

	if event is InputEventPanGesture:
		pan -= event.delta
		_update_texture()


func _desktop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at(event.position, ZOOM_FACTOR)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at(event.position, 1.0 / ZOOM_FACTOR)

		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				dragging = true
				drag_start = event.position
				pan_start = pan
			else:
				dragging = false

	if event is InputEventMouseMotion:
		if not dragging:
			return

		pan = pan_start + (event.position - drag_start)
		_update_texture()


func _update_texture() -> void:
	canvas.position = pan
	canvas.scale = Vector2(zoom, zoom)


func _reset_canvas() -> void:
	pan = Vector2.ZERO
	zoom = 1.0


func _zoom_at(pos: Vector2, factor: float) -> void:
	var old_zoom: float = zoom

	zoom = clampf(zoom * factor, MIN_ZOOM, MAX_ZOOM)

	var local: Vector2 = (pos - pan) / old_zoom
	pan = pos - local * zoom

	_update_texture()
