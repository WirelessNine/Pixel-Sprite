extends PanelContainer

const GORA: Texture2D = preload("uid://d1dklbg81quuo")

const COLOR_BUTTON: PackedScene = preload("uid://q20lx1jb5hcl")
const ColorButton: GDScript = preload("uid://bkuu5uknbkqb7")

@onready var palette_grid: GridContainer = %PaletteGrid
@onready var color_picker: ColorPickerButton = %ColorPicker
@onready var palettes_button: Button = %Palettes

var color_group: ButtonGroup
var color_pool: ScenePool


func _ready() -> void:
	color_group = ButtonGroup.new()
	color_pool = ScenePool.new(
		ScenePool.AccessMode.BATCHED,
		COLOR_BUTTON,
		palette_grid,
		-1,
		10,
		_on_created,
	)

	load_palette(GORA)

	color_picker.color_changed.connect(_on_color_picker_changed)
	palettes_button.pressed.connect(MenuManager.open_menu.bind("palette_menu"))
	AppManager.palette_selected.connect(load_palette)


func load_palette(palette: Texture2D) -> void:
	var image: Image = palette.get_image()
	var width: int = image.get_width()

	var colors: PackedColorArray

	colors.resize(width)

	for x: int in width:
		var pixel_color: Color = image.get_pixel(x, 0)

		colors[x] = pixel_color

	color_pool.update_scenes(colors, _update_button)


func _on_created(button: ColorButton) -> void:
	button.button_group = color_group
	button.pressed.connect(_on_color_pressed.bind(button))

	button.hide()


func _update_button(button: ColorButton, color: Color) -> void:
	button.self_modulate = color

	if button.get_index() == 0:
		button.button_pressed = true
		button.pressed.emit()


func _on_color_pressed(button: ColorButton) -> void:
	color_picker.color = button.self_modulate


func _on_color_picker_changed(new_color: Color) -> void:
	for x: Node in palette_grid.get_children():
		if x.self_modulate == new_color:
			x.button_pressed = true
		else:
			x.button_pressed = false
