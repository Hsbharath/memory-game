extends Node

var _continents: Dictionary = {}
var _rounds: Dictionary = {}

func _ready() -> void:
	_load_all_continents()
	_load_all_rounds()

func _load_all_continents() -> void:
	for continent_id in GameState.CONTINENT_ORDER:
		var path = "res://data/continents/%s.json" % continent_id
		var data = _load_json(path)
		if data:
			_continents[continent_id] = data

func _load_all_rounds() -> void:
	for continent_id in GameState.CONTINENT_ORDER:
		var path = "res://data/rounds/%s_rounds.json" % continent_id
		var data = _load_json(path)
		if data:
			_rounds[continent_id] = data

func _load_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_warning("DataRepository: missing file %s" % path)
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("DataRepository: JSON parse error in %s" % path)
		return null
	return json.get_data()

func get_continent(continent_id: String) -> Dictionary:
	return _continents.get(continent_id, {})

func get_all_continents() -> Array:
	var result = []
	for id in GameState.CONTINENT_ORDER:
		if _continents.has(id):
			result.append(_continents[id])
	return result

func get_round_config(continent_id: String, round_number: int) -> Dictionary:
	var round_data = _rounds.get(continent_id, {})
	var rounds_array = round_data.get("rounds", [])
	for r in rounds_array:
		if r["roundNumber"] == round_number:
			return r
	return {}

func get_all_rounds_for_continent(continent_id: String) -> Array:
	return _rounds.get(continent_id, {}).get("rounds", [])

func get_image_pool(continent_id: String) -> Array:
	return _continents.get(continent_id, {}).get("imagePool", [])

func get_images_for_round(continent_id: String, round_number: int) -> Array:
	var config = get_round_config(continent_id, round_number)
	var grid_size = config.get("gridSize", 2)
	var uses_center = config.get("usesCenterSpecialTile", false)
	var total_slots = grid_size * grid_size
	var playable_slots = total_slots - (1 if uses_center else 0)
	var pair_count = playable_slots / 2
	var pool = get_image_pool(continent_id)
	pool.shuffle()
	var selected = pool.slice(0, pair_count)
	var card_images = selected.duplicate()
	card_images.append_array(selected)
	card_images.shuffle()
	return card_images
