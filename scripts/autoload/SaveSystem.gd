extends Node

const SAVE_PATH = "user://save_data.json"

var _data: Dictionary = {}

func _ready() -> void:
	_load()

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_data = _default_data()
		_flush()
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()
	if err == OK:
		_data = json.get_data()
	else:
		_data = _default_data()
		_flush()

func _flush() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(_data, "\t"))
	file.close()

func _default_data() -> Dictionary:
	return {
		"unlocked_continents": ["africa"],
		"round_results": {},
		"settings": {
			"master_volume": 1.0,
			"music_volume": 0.8,
			"sfx_volume": 1.0,
			"high_contrast": false,
			"reduced_motion": false,
			"language": "en"
		},
		"stats": {
			"total_matches": 0,
			"total_playtime": 0,
			"total_rounds_played": 0
		}
	}

func save_round_result(continent_id: String, round_number: int, stars: int, score: int) -> void:
	var key = "%s_%d" % [continent_id, round_number]
	var existing = _data["round_results"].get(key, {"stars": 0, "score": 0})
	_data["round_results"][key] = {
		"stars": max(existing["stars"], stars),
		"score": max(existing["score"], score)
	}
	_data["stats"]["total_rounds_played"] += 1
	_check_continent_unlock(continent_id)
	_flush()

func get_round_result(continent_id: String, round_number: int) -> Dictionary:
	var key = "%s_%d" % [continent_id, round_number]
	return _data["round_results"].get(key, {"stars": 0, "score": 0})

func is_round_unlocked(continent_id: String, round_number: int) -> bool:
	if round_number == 1:
		return is_continent_unlocked(continent_id)
	return get_round_result(continent_id, round_number - 1)["stars"] > 0

func is_continent_unlocked(continent_id: String) -> bool:
	return continent_id in _data["unlocked_continents"]

func _check_continent_unlock(completed_continent_id: String) -> void:
	var all_done = true
	for r in range(1, 11):
		if get_round_result(completed_continent_id, r)["stars"] == 0:
			all_done = false
			break
	if not all_done:
		return
	var idx = GameState.CONTINENT_ORDER.find(completed_continent_id)
	if idx >= 0 and idx + 1 < GameState.CONTINENT_ORDER.size():
		var next = GameState.CONTINENT_ORDER[idx + 1]
		if next not in _data["unlocked_continents"]:
			_data["unlocked_continents"].append(next)
			GameState.continent_completed.emit(completed_continent_id)

func get_setting(key: String) -> Variant:
	return _data["settings"].get(key, null)

func set_setting(key: String, value: Variant) -> void:
	_data["settings"][key] = value
	_flush()

func add_playtime(seconds: float) -> void:
	_data["stats"]["total_playtime"] += seconds
	_flush()

func add_matches(count: int) -> void:
	_data["stats"]["total_matches"] += count
	_flush()
