extends Button

@onready var flag: TextureRect = $VBoxContainer/Flag
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var lock_icon: Label = $VBoxContainer/LockIcon

func setup(continent: Dictionary, is_unlocked: bool) -> void:
	name_label.text = continent.get("name", "")
	lock_icon.visible = not is_unlocked
	disabled = not is_unlocked
	modulate = Color.WHITE if is_unlocked else Color(0.5, 0.5, 0.5, 1.0)
	if ResourceLoader.exists(continent.get("backgroundArt", "")):
		flag.texture = load(continent["backgroundArt"])
