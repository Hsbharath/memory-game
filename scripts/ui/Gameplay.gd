extends Control

var continent_id: String = ""
var round_number: int = 1

@onready var board: Board = $Board
@onready var hud: HUD = $HUD
@onready var pause_panel: Control = $PausePanel
@onready var round_complete_panel: Control = $RoundCompletePanel

func _ready() -> void:
	pause_panel.visible = false
	round_complete_panel.visible = false

	hud.setup(continent_id, round_number)
	hud.hint_requested.connect(_on_hint)
	hud.pause_requested.connect(_on_pause)

	board.all_pairs_matched.connect(_on_all_matched)

	var config = DataRepository.get_round_config(continent_id, round_number)
	GameState.start_round(continent_id, round_number, config)
	GameState.round_completed.connect(_on_round_completed)

	board.build(continent_id, round_number)

	var preview_secs = config.get("previewSeconds", 3.0)
	await board.preview(preview_secs)

func _on_all_matched() -> void:
	GameState.complete_round()

func _on_round_completed(_cid: String, _rnum: int, stars: int, score: int) -> void:
	AudioController.play_sfx("victory")
	round_complete_panel.show_result(stars, score, continent_id, round_number)
	round_complete_panel.visible = true

func _on_hint() -> void:
	if GameState.use_hint():
		board.reveal_hint()

func _on_pause() -> void:
	get_tree().paused = true
	pause_panel.visible = true

func _on_resume() -> void:
	get_tree().paused = false
	pause_panel.visible = false

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/screens/WorldMap.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not pause_panel.visible:
		_on_pause()
