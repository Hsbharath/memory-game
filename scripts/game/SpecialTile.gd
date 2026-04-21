extends Control
class_name SpecialTile

@onready var badge_texture: TextureRect = $BadgeTexture
@onready var label: Label = $Label

func setup(continent_id: String) -> void:
	var continent = DataRepository.get_continent(continent_id)
	label.text = continent.get("name", "").left(1).to_upper()
	var bg_color = Color(continent.get("themeColor", "#888888"))
	self_modulate = bg_color
