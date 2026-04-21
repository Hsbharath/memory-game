extends Control

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var title_label: Label = $TitleLabel

func _ready() -> void:
	play_button.pressed.connect(_on_play)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)
	AudioController.play_music("res://assets/audio/music/main_menu_theme.ogg")

func _on_play() -> void:
	AudioController.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/screens/WorldMap.tscn")

func _on_settings() -> void:
	AudioController.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/screens/Settings.tscn")

func _on_quit() -> void:
	get_tree().quit()
