extends Control
class_name Board

signal all_pairs_matched

const CARD_SCENE = preload("res://scenes/components/Card.tscn")
const SPECIAL_TILE_SCENE = preload("res://scenes/components/SpecialTile.tscn")
const MISMATCH_DELAY = 0.9

var _grid_size: int = 2
var _uses_center: bool = false
var _cards: Array[Card] = []
var _first_card: Card = null
var _second_card: Card = null
var _is_locked: bool = false
var _matched_count: int = 0
var _total_pairs: int = 0
var _back_texture: Texture2D = null

@onready var grid: GridContainer = $GridContainer

func build(continent_id: String, round_number: int) -> void:
	var config = DataRepository.get_round_config(continent_id, round_number)
	if config.is_empty():
		push_error("Board: empty config for '%s' round %d" % [continent_id, round_number])
		return

	var continent = DataRepository.get_continent(continent_id)
	_grid_size = config.get("gridSize", 2)
	_uses_center = config.get("usesCenterSpecialTile", false)
	_back_texture = null

	var back_path = continent.get("cardBackArt", "")
	if back_path != "" and ResourceLoader.exists(back_path):
		_back_texture = load(back_path)

	var images = DataRepository.get_images_for_round(continent_id, round_number)
	_total_pairs = images.size() / 2
	GameState.total_pairs = _total_pairs

	_clear_grid()
	grid.columns = _grid_size

	var card_size = _calculate_card_size()
	var sep = float(grid.get_theme_constant("h_separation"))
	var board_side = _grid_size * card_size + (_grid_size - 1) * sep

	# Size the Board node itself so CenterContainer can center it
	custom_minimum_size = Vector2(board_side, board_side)
	size = Vector2(board_side, board_side)

	var center_index = (_grid_size * _grid_size) / 2 if _uses_center else -1
	var image_cursor = 0

	for i in range(_grid_size * _grid_size):
		if i == center_index:
			var special = SPECIAL_TILE_SCENE.instantiate()
			special.custom_minimum_size = Vector2(card_size, card_size)
			grid.add_child(special)
			special.setup(continent_id)
		else:
			if image_cursor >= images.size():
				break
			var card: Card = CARD_SCENE.instantiate()
			card.custom_minimum_size = Vector2(card_size, card_size)
			grid.add_child(card)
			card.setup(images[image_cursor], i, _back_texture)
			card.card_clicked.connect(_on_card_clicked)
			_cards.append(card)
			image_cursor += 1

func show_all_cards() -> void:
	for card in _cards:
		if card.state == Card.State.MATCHED:
			continue
		card.state = Card.State.FACE_DOWN
		card.button.disabled = true
		card.flip_up(false)

func blink_preview(total_seconds: float, min_count: int = 4) -> void:
	# Show min_count..min_count+2 random cards at a time, each batch stays open for 5 seconds
	const SHOW_DURATION = 5.0
	var elapsed = 0.0
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	while elapsed < total_seconds:
		var count = rng.randi_range(min_count, min_count + 2)
		var pool = _cards.filter(func(c): return c.state == Card.State.FACE_DOWN)
		if pool.is_empty():
			break
		pool.shuffle()
		var batch = pool.slice(0, min(count, pool.size()))
		for card in batch:
			card.state = Card.State.FACE_DOWN
			card.button.disabled = true
			card.flip_up(false)
		var wait = minf(SHOW_DURATION, total_seconds - elapsed)
		await get_tree().create_timer(wait).timeout
		elapsed += wait
		for card in batch:
			if card.state == Card.State.FACE_UP:
				card.state = Card.State.FACE_UP
				card.button.disabled = false
				card.flip_down(false)
		# Small gap between batches
		if elapsed < total_seconds:
			await get_tree().create_timer(0.3).timeout
			elapsed += 0.3

func hide_all_cards() -> void:
	for card in _cards:
		if card.state == Card.State.MATCHED:
			continue
		card.state = Card.State.FACE_UP
		card.button.disabled = false
		card.flip_down(false)

func reveal_hint() -> void:
	var unmatched = _cards.filter(func(c): return c.state == Card.State.FACE_DOWN)
	if unmatched.is_empty():
		return
	var pick = unmatched[randi() % unmatched.size()]
	var pair = _cards.filter(func(c): return c.image_id == pick.image_id and c != pick)
	pick.flip_up()
	if not pair.is_empty():
		pair[0].flip_up()
	await get_tree().create_timer(1.5).timeout
	if pick.state == Card.State.FACE_UP:
		pick.flip_down()
	if not pair.is_empty() and pair[0].state == Card.State.FACE_UP:
		pair[0].flip_down()

func _on_card_clicked(card: Card) -> void:
	if _is_locked:
		return
	if _first_card == null:
		_first_card = card
		card.flip_up()
	elif _second_card == null and card != _first_card:
		_second_card = card
		card.flip_up()
		_is_locked = true
		_check_match()

func _check_match() -> void:
	if _first_card.image_id == _second_card.image_id:
		_on_match()
	else:
		_on_mismatch()

func _on_match() -> void:
	AudioController.play_sfx("match")
	GameState.register_match()
	_first_card.set_matched()
	_second_card.set_matched()
	_matched_count += 1
	_reset_selection()
	if _matched_count >= _total_pairs:
		await get_tree().create_timer(0.4).timeout
		all_pairs_matched.emit()

func _on_mismatch() -> void:
	AudioController.play_sfx("mismatch")
	GameState.register_mismatch()
	await get_tree().create_timer(MISMATCH_DELAY).timeout
	if is_instance_valid(_first_card):
		_first_card.flip_down()
	if is_instance_valid(_second_card):
		_second_card.flip_down()
	_reset_selection()

func _reset_selection() -> void:
	_first_card = null
	_second_card = null
	_is_locked = false

func _clear_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	_cards.clear()
	_first_card = null
	_second_card = null
	_is_locked = false
	_matched_count = 0

func _calculate_card_size() -> float:
	var vp = get_viewport().get_visible_rect().size
	var sep = float(grid.get_theme_constant("h_separation"))
	var cols = float(_grid_size)
	# Leave 32px padding each side, 64px for HUD bar
	var available_w = vp.x - 64.0
	var available_h = vp.y - 64.0 - 32.0
	var size_from_w = (available_w - (cols - 1.0) * sep) / cols
	var size_from_h = (available_h - (cols - 1.0) * sep) / cols
	return maxf(40.0, minf(size_from_w, size_from_h))
