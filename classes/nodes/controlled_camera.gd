extends Camera2D

const DRAG_WEIGHT: float = 30.0
const ZOOM_INC: float = 0.25
const ZOOM_MIN: float = 1.0
const ZOOM_MAX: float = 30.0

var is_dragging: bool
var target_position: Vector2
var target_zoom: Vector2


func _ready() -> void:
	target_position = position
	target_zoom = zoom


func _physics_process(_delta: float) -> void:
	position = target_position
	zoom = target_zoom


func _unhandled_input(event: InputEvent) -> void:
	if OS.has_feature("mobile"):
		_mobile_input(event)
	else:
		_desktop_input(event)


func _mobile_input(event: InputEvent) -> void:
	if event is InputEventPanGesture:
		target_position += event.delta / target_zoom

	if event is InputEventMagnifyGesture:
		var old_zoom: Vector2 = target_zoom

		target_zoom *= event.factor
		target_zoom.x = clamp(target_zoom.x, ZOOM_MIN, ZOOM_MAX)
		target_zoom.y = clamp(target_zoom.y, ZOOM_MIN, ZOOM_MAX)

		var viewport_size: Vector2 = get_viewport_rect().size
		var gesture_world_pos: Vector2 = target_position + (event.position - viewport_size / 2.0) / old_zoom
		target_position = gesture_world_pos - (event.position - viewport_size / 2.0) / target_zoom


func _desktop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		is_dragging = event.is_pressed()

	if event is InputEventMouseMotion and is_dragging:
		target_position -= event.relative / zoom

	if event is InputEventMouseButton and event.is_pressed():
		if (
			event.button_index == MOUSE_BUTTON_WHEEL_UP
			or event.button_index == MOUSE_BUTTON_WHEEL_DOWN
		):
			var mouse_pos: Vector2 = get_global_mouse_position()

			var old_zoom: Vector2 = target_zoom

			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				target_zoom *= (1.0 + ZOOM_INC)
			else:
				target_zoom /= (1.0 + ZOOM_INC)

			target_zoom.x = clamp(target_zoom.x, ZOOM_MIN, ZOOM_MAX)
			target_zoom.y = clamp(target_zoom.y, ZOOM_MIN, ZOOM_MAX)

			target_position = mouse_pos + (target_position - mouse_pos) * (old_zoom / target_zoom)
