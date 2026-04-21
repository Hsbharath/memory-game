extends Control

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Panel/VBoxContainer/RestartButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

signal resume_pressed
signal restart_pressed
signal quit_pressed

func _ready() -> void:
	resume_button.pressed.connect(func(): AudioController.play_sfx("button"); resume_pressed.emit())
	restart_button.pressed.connect(func(): AudioController.play_sfx("button"); restart_pressed.emit())
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(func(): AudioController.play_sfx("button"); quit_pressed.emit())

func _on_settings() -> void:
	AudioController.play_sfx("button")
