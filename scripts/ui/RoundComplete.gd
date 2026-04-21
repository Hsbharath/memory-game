extends Control

@onready var stars_container: HBoxContainer = $Panel/VBoxContainer/StarsContainer
@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var next_button: Button = $Panel/VBoxContainer/HBoxContainer/NextButton
@onready var replay_button: Button = $Panel/VBoxContainer/HBoxContainer/ReplayButton
@onready var menu_button: Button = $Panel/VBoxContainer/HBoxContainer/MenuButton

var _continent_id: String
var _round_number: int

func _ready() -> void:
	next_button.pressed.connect(_on_next)
	replay_button.pressed.connect(_on_replay)
	menu_button.pressed.connect(_on_menu)

func show_result(stars: int, score: int, continent_id: String, round_number: int) -> void:
	_continent_id = continent_id
	_round_number = round_number
	score_label.text = "Score: %d" % score
	_display_stars(stars)

	var is_last_round = round_number >= 10
	next_button.visible = not is_last_round and SaveSystem.is_round_unlocked(continent_id, round_number + 1)

func _display_stars(count: int) -> void:
	for i in range(stars_container.get_child_count()):
		var star = stars_container.get_child(i)
		star.modulate = Color.YELLOW if i < count else Color(0.3, 0.3, 0.3)

func _on_next() -> void:
	AudioController.play_sfx("button")
	var gameplay = get_parent()
	var scene = load("res://scenes/screens/Gameplay.tscn").instantiate()
	scene.continent_id = _continent_id
	scene.round_number = _round_number + 1
	get_tree().root.add_child(scene)
	gameplay.queue_free()

func _on_replay() -> void:
	AudioController.play_sfx("button")
	var gameplay = get_parent()
	var scene = load("res://scenes/screens/Gameplay.tscn").instantiate()
	scene.continent_id = _continent_id
	scene.round_number = _round_number
	get_tree().root.add_child(scene)
	gameplay.queue_free()

func _on_menu() -> void:
	AudioController.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/screens/RoundSelect.tscn")
