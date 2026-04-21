extends Control
class_name Card

signal card_clicked(card: Card)

enum State { FACE_DOWN, FLIPPING, FACE_UP, MATCHED, LOCKED }

@export var flip_duration: float = 0.2

var image_id: String = ""
var card_index: int = -1
var state: State = State.FACE_DOWN

@onready var back_rect: ColorRect = $Back
@onready var back_label: Label = $BackLabel
@onready var front_rect: ColorRect = $Front
@onready var front_texture: TextureRect = $FrontTexture
@onready var front_label: Label = $FrontLabel
@onready var match_overlay: ColorRect = $MatchOverlay
@onready var button: Button = $Button

func _ready() -> void:
	button.pressed.connect(_on_pressed)
	match_overlay.visible = false
	_show_back()

func setup(img_id: String, idx: int, back_texture: Texture2D) -> void:
	image_id = img_id
	card_index = idx

	if back_texture != null:
		back_rect.color = Color(0.15, 0.25, 0.55, 1)

	front_texture.texture = null
	if img_id != "":
		var tex = load(img_id) if ResourceLoader.exists(img_id) else null
		if tex is Texture2D:
			front_texture.texture = tex

	if front_texture.texture == null:
		var short_name = img_id.get_file().get_basename().replace("_", " ").replace(",", "")
		front_label.text = short_name

func flip_up(animate: bool = true) -> void:
	if state == State.MATCHED or state == State.LOCKED or state == State.FACE_UP:
		return
	state = State.FLIPPING
	button.disabled = true
	if animate:
		_animate_flip(true)
	else:
		_show_front()
		state = State.FACE_UP

func flip_down(animate: bool = true) -> void:
	if state == State.MATCHED or state == State.LOCKED or state == State.FACE_DOWN:
		return
	state = State.FLIPPING
	if animate:
		_animate_flip(false)
	else:
		_show_back()
		state = State.FACE_DOWN
		button.disabled = false

func set_matched() -> void:
	state = State.MATCHED
	button.disabled = true
	match_overlay.visible = true
	var tween = create_tween()
	tween.tween_property(match_overlay, "modulate:a", 0.0, 0.8)

func set_locked(locked: bool) -> void:
	if state == State.MATCHED:
		return
	state = State.LOCKED if locked else State.FACE_DOWN
	button.disabled = locked

func _on_pressed() -> void:
	if state != State.FACE_DOWN:
		return
	AudioController.play_sfx("flip")
	card_clicked.emit(self)

func _animate_flip(to_front: bool) -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 0.0, flip_duration * 0.5)
	tween.tween_callback(func():
		if to_front:
			_show_front()
		else:
			_show_back()
	)
	tween.tween_property(self, "scale:x", 1.0, flip_duration * 0.5)
	tween.tween_callback(func():
		if to_front:
			state = State.FACE_UP
			button.disabled = true
		else:
			state = State.FACE_DOWN
			button.disabled = false
	)

func _show_front() -> void:
	back_rect.visible = false
	back_label.visible = false
	if front_texture.texture != null:
		front_rect.visible = false
		front_texture.visible = true
		front_label.visible = false
	else:
		front_rect.visible = true
		front_texture.visible = false
		front_label.visible = true

func _show_back() -> void:
	back_rect.visible = true
	back_label.visible = true
	front_rect.visible = false
	front_texture.visible = false
	front_label.visible = false
