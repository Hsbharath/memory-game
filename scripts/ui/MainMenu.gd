extends Control

const LOGO_PATH     = "res://assets/images/memory_map.jpeg"
const PLAY_PATH     = "res://assets/images/play.jpeg"
const SETTINGS_PATH = "res://assets/images/settings.jpeg"
const QUIT_PATH     = "res://assets/images/end.jpeg"

@onready var logo:            TextureRect = $Logo
@onready var play_button:     Button      = $PlayButton
@onready var play_icon:       TextureRect = $PlayButton/PlayIcon
@onready var settings_button: Button      = $TopRightIcons/SettingsButton
@onready var settings_icon:   TextureRect = $TopRightIcons/SettingsButton/SettingsIcon
@onready var quit_button:     Button      = $TopRightIcons/QuitButton
@onready var quit_icon:       TextureRect = $TopRightIcons/QuitButton/QuitIcon

func _ready() -> void:
	_load_textures()
	_size_logo()
	play_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	settings_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	quit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	play_button.pressed.connect(_on_play)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)
	AudioController.play_music("res://assets/audio/music/main_menu_theme.ogg")

func _load_textures() -> void:
	if ResourceLoader.exists(LOGO_PATH):
		logo.texture = load(LOGO_PATH)
	if ResourceLoader.exists(PLAY_PATH):
		play_icon.texture = load(PLAY_PATH)
	if ResourceLoader.exists(SETTINGS_PATH):
		settings_icon.texture = load(SETTINGS_PATH)
	if ResourceLoader.exists(QUIT_PATH):
		quit_icon.texture = load(QUIT_PATH)

func _size_logo() -> void:
	var vp = get_viewport().get_visible_rect().size
	var w = vp.x * 0.8
	var h = vp.y * 0.8
	logo.offset_left   = -w * 0.5
	logo.offset_top    = -h * 0.5
	logo.offset_right  =  w * 0.5
	logo.offset_bottom =  h * 0.5
	logo.mouse_filter  = Control.MOUSE_FILTER_IGNORE

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/WorldMap.tscn")

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/Settings.tscn")

func _on_quit() -> void:
	get_tree().quit()
