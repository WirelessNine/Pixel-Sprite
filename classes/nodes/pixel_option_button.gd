class_name PixelOptionButton
extends OptionButton


func _init() -> void:
	get_popup().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	get_popup().theme_type_variation = &"popup_connected"
