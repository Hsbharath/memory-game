extends CanvasLayer
class_name HUD

@onready var score_label: Label = $HUDPanel/HBoxContainer/ScoreLabel
@onready var combo_label: Label = $HUDPanel/HBoxContainer/ComboLabel
@onready var timer_label: Label = $HUDPanel/HBoxContainer/TimerLabel
@onready var hints_label: Label = $HUDPanel/HBoxContainer/HintsLabel
@onready var hint_button: Button = $HUDPanel/HBoxContainer/HintButton
@onready var pause_button: Button = $HUDPanel/HBoxContainer/PauseButton
@onready var round_label: Label = $HUDPanel/HBoxContainer/RoundLabel

signal hint_requested
signal pause_requested

func _ready() -> void:
	hint_button.pressed.connect(_on_hint_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	GameState.score_changed.connect(_on_score_changed)
	GameState.combo_changed.connect(_on_combo_changed)
	GameState.timer_tick.connect(_on_timer_tick)
	GameState.hints_changed.connect(_on_hints_changed)

func setup(continent_id: String, round_number: int) -> void:
	var config = DataRepository.get_round_config(continent_id, round_number)
	round_label.text = "Round %d" % round_number
	score_label.text = "0"
	combo_label.text = ""
	timer_label.visible = config.get("timerSeconds", 0) > 0
	var hints = config.get("hintCount", 0)
	hints_label.text = "Hints: %d" % hints
	hint_button.disabled = hints == 0

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

func _on_hint_pressed() -> void:
	AudioController.play_sfx("hint")
	hint_requested.emit()

func _on_pause_pressed() -> void:
	AudioController.play_sfx("button")
	pause_requested.emit()
