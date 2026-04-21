extends Control

@onready var master_slider: HSlider = $Panel/VBoxContainer/MasterVolume/HSlider
@onready var music_slider: HSlider = $Panel/VBoxContainer/MusicVolume/HSlider
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/SFXVolume/HSlider
@onready var high_contrast_check: CheckButton = $Panel/VBoxContainer/HighContrast/CheckButton
@onready var reduced_motion_check: CheckButton = $Panel/VBoxContainer/ReducedMotion/CheckButton
@onready var back_button: Button = $BackButton

func _ready() -> void:
	master_slider.value = SaveSystem.get_setting("master_volume")
	music_slider.value = SaveSystem.get_setting("music_volume")
	sfx_slider.value = SaveSystem.get_setting("sfx_volume")
	high_contrast_check.button_pressed = SaveSystem.get_setting("high_contrast")
	reduced_motion_check.button_pressed = SaveSystem.get_setting("reduced_motion")

	master_slider.value_changed.connect(func(v): AudioController.set_master_volume(v))
	music_slider.value_changed.connect(func(v): AudioController.set_music_volume(v))
	sfx_slider.value_changed.connect(func(v): AudioController.set_sfx_volume(v))
	high_contrast_check.toggled.connect(func(v): SaveSystem.set_setting("high_contrast", v))
	reduced_motion_check.toggled.connect(func(v): SaveSystem.set_setting("reduced_motion", v))
	back_button.pressed.connect(_on_back)

func _on_back() -> void:
	AudioController.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/screens/MainMenu.tscn")
