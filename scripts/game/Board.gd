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
	var continent = DataRepository.get_continent(continent_id)

	_grid_size = config.get("gridSize", 2)
	_uses_center = config.get("usesCenterSpecialTile", false)

	if ResourceLoader.exists(continent.get("cardBackArt", "")):
		_back_texture = load(continent["cardBackArt"])

	var images = DataRepository.get_images_for_round(continent_id, round_number)
	_total_pairs = images.size() / 2
	GameState.total_pairs = _total_pairs

	_clear()
	grid.columns = _grid_size
	_size_cards()

	var center_index = (_grid_size * _grid_size) / 2 if _uses_center else -1
	var image_cursor = 0

	for i in range(_grid_size * _grid_size):
		if i == center_index:
			var special = SPECIAL_TILE_SCENE.instantiate()
			special.setup(continent_id)
			grid.add_child(special)
		else:
			var card: Card = CARD_SCENE.instantiate()
			grid.add_child(card)
			card.setup(images[image_cursor], i, _back_texture)
			card.card_clicked.connect(_on_card_clicked)
			_cards.append(card)
			image_cursor += 1

func preview(seconds: float) -> void:
	for card in _cards:
		card.flip_up(false)
	await get_tree().create_timer(seconds).timeout
	for card in _cards:
		if card.state != Card.State.MATCHED:
			card.flip_down(false)
			card.state = Card.State.FACE_DOWN
			card.button.disabled = false

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
	_first_card.flip_down()
	_second_card.flip_down()
	_reset_selection()

func _reset_selection() -> void:
	_first_card = null
	_second_card = null
	_is_locked = false

func _clear() -> void:
	for child in grid.get_children():
		child.queue_free()
	_cards.clear()
	_first_card = null
	_second_card = null
	_is_locked = false
	_matched_count = 0

func _size_cards() -> void:
	var available = size
	var card_size = min(
		(available.x - (_grid_size - 1) * grid.get_theme_constant("h_separation")) / _grid_size,
		(available.y - (_grid_size - 1) * grid.get_theme_constant("v_separation")) / _grid_size
	)
	for child in grid.get_children():
		child.custom_minimum_size = Vector2(card_size, card_size)
