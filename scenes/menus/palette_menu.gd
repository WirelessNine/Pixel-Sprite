extends Menu

const GORA: Texture2D = preload("uid://d1dklbg81quuo")
const MORNING: Texture2D = preload("uid://50n1jr2am4g2")
const RESURRECT: Texture2D = preload("uid://c800xtfetlh0u")
const ROSY: Texture2D = preload("uid://dxm8qqueuy3nh")

const PALETTES: Dictionary[String, Texture2D] = {
	"Gora - Biganon": GORA,
	"Morning - Yousurname": MORNING,
	"Resurrect - Kerrie Lake": RESURRECT,
	"Rosy - PineappleOnPizza": ROSY,
}

@onready var list: ItemList = %List


func _ready() -> void:
	for x: String in PALETTES:
		var index: int = list.add_item(x)
		list.set_item_metadata(index, PALETTES[x])

	list.select(0)


func _on_list_item_selected(index: int) -> void:
	AppManager.palette_selected.emit(list.get_item_metadata(index))
	close()


func _on_cancel_pressed() -> void:
	close()
