extends TextureButton

@onready var toggle_outline: Panel = $ToggleOutline


func _toggled(toggled_on: bool) -> void:
	toggle_outline.visible = toggled_on
