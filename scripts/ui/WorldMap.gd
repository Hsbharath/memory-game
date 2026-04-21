extends Control

const CONTINENT_BUTTON_SCENE = preload("res://scenes/components/ContinentButton.tscn")

@onready var continents_container: HFlowContainer = $ScrollContainer/ContinentsContainer
@onready var back_button: Button = $BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back)
	_populate_continents()

func _populate_continents() -> void:
	for child in continents_container.get_children():
		child.queue_free()

	for continent in DataRepository.get_all_continents():
		var btn = CONTINENT_BUTTON_SCENE.instantiate()
		continents_container.add_child(btn)
		var is_unlocked = SaveSystem.is_continent_unlocked(continent["id"])
		btn.setup(continent, is_unlocked)
		btn.pressed.connect(_on_continent_selected.bind(continent["id"], is_unlocked))

func _on_continent_selected(continent_id: String, is_unlocked: bool) -> void:
	if not is_unlocked:
		return
	GameState.pending_continent_id = continent_id
	get_tree().change_scene_to_file("res://scenes/screens/RoundSelect.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/MainMenu.tscn")
