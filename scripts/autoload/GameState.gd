extends Node

signal round_started(continent_id: String, round_number: int)
signal round_completed(continent_id: String, round_number: int, stars: int, score: int)
signal continent_completed(continent_id: String)
signal score_changed(new_score: int)
signal combo_changed(combo: int)
signal hints_changed(hints_remaining: int)
signal timer_tick(seconds_remaining: float)

const CONTINENT_ORDER = [
	"africa", "asia", "europe", "north_america",
	"south_america", "australia", "antarctica"
]

# Set before changing to Gameplay scene so _ready can read them
var pending_continent_id: String = ""
var pending_round_number: int = 1

var current_continent_id: String = ""
var current_round_number: int = 0
var current_score: int = 0
var current_combo: int = 0
var hints_remaining: int = 0
var timer_seconds: float = 0.0
var is_timer_active: bool = false
var matched_pairs: int = 0
var total_pairs: int = 0
var attempts: int = 0

var _timer: float = 0.0

func _process(delta: float) -> void:
	if not is_timer_active or timer_seconds <= 0.0:
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = 0.0
		is_timer_active = false
		timer_tick.emit(0.0)
		_on_time_expired()
	else:
		timer_tick.emit(_timer)

func start_round(continent_id: String, round_number: int, config: Dictionary) -> void:
	current_continent_id = continent_id
	current_round_number = round_number
	current_score = 0
	current_combo = 0
	matched_pairs = 0
	attempts = 0
	hints_remaining = config.get("hintCount", 0)
	timer_seconds = config.get("timerSeconds", 0)
	_timer = timer_seconds
	is_timer_active = timer_seconds > 0
	round_started.emit(continent_id, round_number)

func register_match(base_points: int = 100) -> void:
	current_combo += 1
	var multiplier = DataRepository.get_round_config(current_continent_id, current_round_number).get("scoreMultiplier", 1.0)
	var combo_bonus = 1.0 + (current_combo - 1) * 0.1
	var time_bonus = _calculate_time_bonus()
	var points = int(base_points * multiplier * combo_bonus + time_bonus)
	current_score += points
	matched_pairs += 1
	score_changed.emit(current_score)
	combo_changed.emit(current_combo)

func register_mismatch() -> void:
	current_combo = 0
	attempts += 1
	combo_changed.emit(current_combo)

func use_hint() -> bool:
	if hints_remaining <= 0:
		return false
	hints_remaining -= 1
	hints_changed.emit(hints_remaining)
	return true

func complete_round() -> void:
	is_timer_active = false
	var stars = _calculate_stars()
	round_completed.emit(current_continent_id, current_round_number, stars, current_score)
	SaveSystem.save_round_result(current_continent_id, current_round_number, stars, current_score)

func _calculate_stars() -> int:
	var accuracy = 1.0
	if attempts + matched_pairs > 0:
		accuracy = float(matched_pairs) / float(matched_pairs + attempts)
	if accuracy >= 0.9 and (_timer > timer_seconds * 0.5 or timer_seconds == 0):
		return 3
	elif accuracy >= 0.7:
		return 2
	else:
		return 1

func _calculate_time_bonus() -> float:
	if timer_seconds <= 0:
		return 0.0
	return (_timer / timer_seconds) * 50.0

func _on_time_expired() -> void:
	complete_round()
