extends Control

const BACK_PATH = "res://assets/images/back.png"

const PIN_POSITIONS = [
	Vector2(0.52, 0.88),
	Vector2(0.44, 0.80),
	Vector2(0.60, 0.74),
	Vector2(0.38, 0.65),
	Vector2(0.55, 0.57),
	Vector2(0.42, 0.48),
	Vector2(0.62, 0.40),
	Vector2(0.35, 0.32),
	Vector2(0.50, 0.22),
	Vector2(0.45, 0.12),
]

const PIN_RADIUS = 26
const ZOOM_FROM = 1.55
const ZOOM_DURATION = 0.85
const PATH_DURATION = 1.1
const PULSE_DURATION = 0.6

const DONE_COLOR = Color(0.2, 0.85, 0.3, 1.0)
const ACTIVE_COLOR = Color(1.0, 0.65, 0.1, 1.0)
const LOCK_COLOR = Color(0.3, 0.3, 0.35, 1.0)

var continent_id: String = ""
var _pin_buttons: Array[Button] = []

@onready var map_background: TextureRect = $MapBackground
@onready var path_canvas: Control = $PathCanvas
@onready var pins_container: Control = $PinsContainer
@onready var continent_label: Label = $TopBar/ContinentLabel
@onready var back_button: Button = $BottomBar/BackButton
@onready var back_icon: TextureRect = $BottomBar/BackButton/BackIcon

func _ready() -> void:
	if continent_id == "":
		continent_id = GameState.pending_continent_id

	if ResourceLoader.exists(BACK_PATH):
		back_icon.texture = load(BACK_PATH)

	back_button.pressed.connect(_on_back)

	var continent = DataRepository.get_continent(continent_id)
	continent_label.text = continent.get("name", "")
	AudioController.play_music(continent.get("musicTrack", ""))

	var map_path = continent.get("mapImage", "")
	if map_path != "" and ResourceLoader.exists(map_path):
		map_background.texture = load(map_path)

	_build_pins()
	_run_intro_animation()

func _build_pins() -> void:
	for child in pins_container.get_children():
		child.queue_free()
	_pin_buttons.clear()

	var vp = get_viewport().get_visible_rect().size
	var safe_top = 64.0
	var safe_bottom = vp.y - 80.0

	for i in range(10):
		var round_num = i + 1
		var norm = PIN_POSITIONS[i]
		var px = norm.x * vp.x
		var py = clampf(norm.y * vp.y, safe_top + PIN_RADIUS, safe_bottom - PIN_RADIUS)

		var is_unlocked = SaveSystem.is_round_unlocked(continent_id, round_num)
		var result = SaveSystem.get_round_result(continent_id, round_num)
		var is_done = result.get("stars", 0) > 0

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(PIN_RADIUS * 2, PIN_RADIUS * 2)
		btn.size = Vector2(PIN_RADIUS * 2, PIN_RADIUS * 2)
		btn.position = Vector2(px - PIN_RADIUS, py - PIN_RADIUS)
		btn.flat = true
		btn.text = str(round_num)
		btn.add_theme_font_size_override("font_size", 14)

		var pin_color = DONE_COLOR if is_done else (ACTIVE_COLOR if is_unlocked else LOCK_COLOR)
		var style = StyleBoxFlat.new()
		style.bg_color = pin_color
		style.corner_radius_top_left = PIN_RADIUS
		style.corner_radius_top_right = PIN_RADIUS
		style.corner_radius_bottom_left = PIN_RADIUS
		style.corner_radius_bottom_right = PIN_RADIUS
		var hover_style = style.duplicate()
		hover_style.bg_color = pin_color.lightened(0.15)
		var focus_style = StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.add_theme_stylebox_override("focus", focus_style)
		btn.add_theme_color_override("font_color", Color.WHITE)

		btn.modulate.a = 0.0
		pins_container.add_child(btn)
		_pin_buttons.append(btn)

		btn.pressed.connect(_on_round_selected.bind(round_num, is_unlocked))

	if path_canvas.has_method("set_pin_positions"):
		var positions: Array[Vector2] = []
		for i in range(10):
			var norm = PIN_POSITIONS[i]
			var vp2 = get_viewport().get_visible_rect().size
			var safe_top2 = 64.0
			var safe_bottom2 = vp2.y - 80.0
			var px2 = norm.x * vp2.x
			var py2 = clampf(norm.y * vp2.y, safe_top2 + PIN_RADIUS, safe_bottom2 - PIN_RADIUS)
			positions.append(Vector2(px2, py2))
		path_canvas.set_pin_positions(positions)

func _run_intro_animation() -> void:
	pivot_offset = get_viewport().get_visible_rect().size * 0.5
	scale = Vector2(ZOOM_FROM, ZOOM_FROM)
	modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, ZOOM_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(_reveal_paths)

func _reveal_paths() -> void:
	if path_canvas.has_method("animate_reveal"):
		path_canvas.animate_reveal(PATH_DURATION)
	var timer = get_tree().create_timer(PATH_DURATION)
	await timer.timeout
	_reveal_pins()

func _reveal_pins() -> void:
	for i in range(_pin_buttons.size()):
		var btn = _pin_buttons[i]
		var tween = create_tween()
		tween.tween_interval(i * 0.08)
		tween.tween_property(btn, "modulate:a", 1.0, 0.25)
		tween.tween_callback(func(): _pulse_pin(btn))

func _pulse_pin(btn: Button) -> void:
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.2, 1.2), PULSE_DURATION * 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", Vector2.ONE, PULSE_DURATION * 0.5).set_ease(Tween.EASE_IN)

func _on_round_selected(round_number: int, is_unlocked: bool) -> void:
	if not is_unlocked:
		return
	AudioController.play_sfx("button")
	GameState.pending_continent_id = continent_id
	GameState.pending_round_number = round_number
	get_tree().change_scene_to_file("res://scenes/screens/Gameplay.tscn")

func _on_back() -> void:
	AudioController.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/screens/WorldMap.tscn")
