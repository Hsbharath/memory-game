extends Control

var continent_id: String = ""
var round_number: int = 0

@onready var board: Board = $BoardArea/Board
@onready var round_label: Label = $HUDBar/HBoxContainer/RoundLabel
@onready var score_label: Label = $HUDBar/HBoxContainer/ScoreLabel
@onready var combo_label: Label = $HUDBar/HBoxContainer/ComboLabel
@onready var preview_timer_label: Label = $HUDBar/HBoxContainer/PreviewTimerLabel
@onready var timer_label: Label = $HUDBar/HBoxContainer/TimerLabel
@onready var hints_label: Label = $HUDBar/HBoxContainer/HintsLabel
@onready var hint_button: Button = $HUDBar/HBoxContainer/HintButton
@onready var pause_button: Button = $HUDBar/HBoxContainer/PauseButton

@onready var pause_panel: Control = $PauseLayer/PausePanel
@onready var resume_button: Button = $PauseLayer/PausePanel/Panel/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PauseLayer/PausePanel/Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $PauseLayer/PausePanel/Panel/VBoxContainer/QuitButton

@onready var complete_panel: Control = $CompleteLayer/CompletePanel
@onready var complete_score_label: Label = $CompleteLayer/CompletePanel/Panel/VBoxContainer/ScoreLabel
@onready var star1: Label = $CompleteLayer/CompletePanel/Panel/VBoxContainer/StarsContainer/Star1
@onready var star2: Label = $CompleteLayer/CompletePanel/Panel/VBoxContainer/StarsContainer/Star2
@onready var star3: Label = $CompleteLayer/CompletePanel/Panel/VBoxContainer/StarsContainer/Star3
@onready var next_button: Button = $CompleteLayer/CompletePanel/Panel/VBoxContainer/HBoxContainer/NextButton
@onready var replay_button: Button = $CompleteLayer/CompletePanel/Panel/VBoxContainer/HBoxContainer/ReplayButton
@onready var menu_button: Button = $CompleteLayer/CompletePanel/Panel/VBoxContainer/HBoxContainer/MenuButton

func _ready() -> void:
	pause_panel.visible = false
	complete_panel.visible = false
	combo_label.visible = false
	preview_timer_label.visible = false

	hint_button.pressed.connect(_on_hint)
	pause_button.pressed.connect(_on_pause)

	resume_button.pressed.connect(_on_resume)
	restart_button.pressed.connect(_on_restart)
	quit_button.pressed.connect(_on_quit)

	next_button.pressed.connect(_on_next)
	replay_button.pressed.connect(_on_replay)
	menu_button.pressed.connect(_on_menu)

	GameState.score_changed.connect(_on_score_changed)
	GameState.combo_changed.connect(_on_combo_changed)
	GameState.timer_tick.connect(_on_timer_tick)
	GameState.preview_tick.connect(_on_preview_tick)
	GameState.preview_ended.connect(_on_preview_ended)
	GameState.hints_changed.connect(_on_hints_changed)
	GameState.round_completed.connect(_on_round_completed)

	board.all_pairs_matched.connect(_on_all_matched)

	call_deferred("_start_round")

func _start_round() -> void:
	if continent_id == "":
		continent_id = GameState.pending_continent_id
	if round_number == 0:
		round_number = GameState.pending_round_number

	var config = DataRepository.get_round_config(continent_id, round_number)
	if config.is_empty():
		push_error("Gameplay: no config for '%s' round %d" % [continent_id, round_number])
		return

	round_label.text = "Round %d" % round_number
	score_label.text = "0"
	var hints = config.get("hintCount", 0)
	hints_label.text = "Hints: %d" % hints
	hint_button.disabled = true
	timer_label.visible = false

	GameState.start_round(continent_id, round_number, config)
	board.build(continent_id, round_number)

	var preview_secs = config.get("previewSeconds", 5.0)
	preview_timer_label.visible = true
	preview_timer_label.text = "Preview: %d" % int(preview_secs)
	if round_number == 10:
		preview_timer_label.text = "?! %d" % int(preview_secs)
		board.blink_preview(preview_secs, 2)
	elif round_number == 9:
		preview_timer_label.text = "?! %d" % int(preview_secs)
		board.blink_preview(preview_secs, 4)
	else:
		board.show_all_cards()
	GameState.start_preview(preview_secs)

func _on_preview_tick(seconds: float) -> void:
	preview_timer_label.text = "Preview: %d" % int(ceil(seconds))

func _on_preview_ended() -> void:
	preview_timer_label.visible = false
	board.hide_all_cards()
	var config = DataRepository.get_round_config(continent_id, round_number)
	var hints = config.get("hintCount", 0)
	hint_button.disabled = hints == 0
	timer_label.visible = config.get("timerSeconds", 0) > 0
	GameState.begin_solve_timer()

func _on_score_changed(score: int) -> void:
	score_label.text = str(score)

func _on_combo_changed(combo: int) -> void:
	if combo >= 2:
		combo_label.text = "x%d Combo!" % combo
		combo_label.visible = true
	else:
		combo_label.visible = false

func _on_timer_tick(seconds: float) -> void:
	var s = int(seconds)
	timer_label.text = "%d:%02d" % [s / 60, s % 60]
	timer_label.modulate = Color.RED if seconds < 15 else Color.WHITE

func _on_hints_changed(hints: int) -> void:
	hints_label.text = "Hints: %d" % hints
	hint_button.disabled = hints == 0

func _on_all_matched() -> void:
	GameState.complete_round()

func _on_round_completed(_cid: String, _rnum: int, stars: int, score: int) -> void:
	complete_score_label.text = "Score: %d" % score
	var stars_nodes = [star1, star2, star3]
	for i in 3:
		stars_nodes[i].modulate = Color.YELLOW if i < stars else Color(0.3, 0.3, 0.3)
	next_button.visible = round_number < 10
	complete_panel.visible = true

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
	GameState.pending_continent_id = continent_id
	GameState.pending_round_number = round_number
	get_tree().change_scene_to_file("res://scenes/screens/Gameplay.tscn")

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/screens/WorldMap.tscn")

func _on_next() -> void:
	GameState.pending_continent_id = continent_id
	GameState.pending_round_number = round_number + 1
	get_tree().change_scene_to_file("res://scenes/screens/Gameplay.tscn")

func _on_replay() -> void:
	GameState.pending_continent_id = continent_id
	GameState.pending_round_number = round_number
	get_tree().change_scene_to_file("res://scenes/screens/Gameplay.tscn")

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/WorldMap.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if pause_panel.visible:
			_on_resume()
		else:
			_on_pause()
