extends Control

const ROUND_BUTTON_SCENE = preload("res://scenes/components/RoundButton.tscn")

var continent_id: String = ""

@onready var rounds_container: GridContainer = $ScrollContainer/RoundsContainer
@onready var back_button: Button = $BackButton
@onready var continent_label: Label = $ContinentLabel

func _ready() -> void:
	back_button.pressed.connect(_on_back)
	var continent = DataRepository.get_continent(continent_id)
	continent_label.text = continent.get("name", "")
	AudioController.play_music(continent.get("musicTrack", ""))
	_populate_rounds()

func _populate_rounds() -> void:
	for child in rounds_container.get_children():
		child.queue_free()

	var rounds = DataRepository.get_all_rounds_for_continent(continent_id)
	for round_config in rounds:
		var btn = ROUND_BUTTON_SCENE.instantiate()
		rounds_container.add_child(btn)
		var round_num = round_config["roundNumber"]
		var result = SaveSystem.get_round_result(continent_id, round_num)
		var is_unlocked = SaveSystem.is_round_unlocked(continent_id, round_num)
		btn.setup(round_num, result["stars"], is_unlocked)
		btn.pressed.connect(_on_round_selected.bind(round_num, is_unlocked))

func _on_round_selected(round_number: int, is_unlocked: bool) -> void:
	if not is_unlocked:
		return
	AudioController.play_sfx("button")
	var scene = load("res://scenes/screens/Gameplay.tscn").instantiate()
	scene.continent_id = continent_id
	scene.round_number = round_number
	get_tree().root.add_child(scene)
	queue_free()

func _on_back() -> void:
	AudioController.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/screens/WorldMap.tscn")
