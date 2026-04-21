extends Control
class_name SpecialTile

const LOGO_PATH = "res://assets/images/memory_map.jpeg"

@onready var logo: TextureRect = $Logo

func setup(_continent_id: String) -> void:
	if ResourceLoader.exists(LOGO_PATH):
		logo.texture = load(LOGO_PATH)
