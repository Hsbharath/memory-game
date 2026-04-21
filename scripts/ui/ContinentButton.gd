extends Control

signal pressed

const LOCK_PATH = "res://assets/images/end.jpeg"

@onready var card:       Button      = $Card
@onready var image:      TextureRect = $Card/Image
@onready var name_label: Label       = $Card/NameLabel
@onready var lock_icon:  TextureRect = $Card/LockIcon

var _is_unlocked: bool = false

func setup(continent: Dictionary, is_unlocked: bool) -> void:
	_is_unlocked = is_unlocked
	name_label.text = continent.get("name", "")

	var img_path = "res://assets/images/%s.jpeg" % continent.get("id", "")
	if ResourceLoader.exists(img_path):
		image.texture = load(img_path)

	if is_unlocked:
		lock_icon.visible = false
		card.disabled = false
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.pressed.connect(func(): pressed.emit())
	else:
		if ResourceLoader.exists(LOCK_PATH):
			lock_icon.texture = load(LOCK_PATH)
		lock_icon.visible = true
		card.disabled = true
		card.mouse_default_cursor_shape = Control.CURSOR_ARROW
