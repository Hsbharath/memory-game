extends Control

var pin_centers: Array[Vector2] = []
var round_unlocked: Array[bool] = []
var draw_progress: float = 0.0  # 0..1 controls how much of the path is drawn

const PATH_UNLOCKED = Color(1.0, 0.82, 0.2, 1.0)
const PATH_LOCKED   = Color(0.55, 0.55, 0.55, 0.6)
const PATH_WIDTH    = 6.0

func set_pin_positions(positions: Array[Vector2]) -> void:
	pin_centers = positions
	round_unlocked.clear()
	for i in range(positions.size()):
		round_unlocked.append(SaveSystem.is_round_unlocked(
			GameState.pending_continent_id, i + 1))
	queue_redraw()

func animate_reveal(duration: float) -> void:
	draw_progress = 0.0
	var tween = create_tween()
	tween.tween_property(self, "draw_progress", 1.0, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(queue_redraw)

func _process(_delta: float) -> void:
	if draw_progress > 0.0 and draw_progress < 1.0:
		queue_redraw()

func _draw() -> void:
	if pin_centers.size() < 2:
		return

	var total_segments = pin_centers.size() - 1
	var total_drawn    = draw_progress * total_segments

	for i in total_segments:
		if float(i) >= total_drawn:
			break

		var a    = pin_centers[i]
		var b    = pin_centers[i + 1]
		var ctrl = _control_point(i)
		var col  = PATH_UNLOCKED if (i + 1 < round_unlocked.size() and round_unlocked[i + 1]) else PATH_LOCKED

		# How much of this segment to draw
		var seg_progress = clampf(total_drawn - float(i), 0.0, 1.0)
		_draw_bezier(a, ctrl, b, col, seg_progress)

func _draw_bezier(a: Vector2, ctrl: Vector2, b: Vector2, col: Color, t_max: float) -> void:
	var steps = 30
	var prev  = a
	for s in steps:
		var t    = (float(s) + 1.0) / float(steps) * t_max
		var pt   = _bezier(a, ctrl, b, t)
		draw_line(prev, pt, col, PATH_WIDTH, true)
		prev = pt

func _bezier(a: Vector2, ctrl: Vector2, b: Vector2, t: float) -> Vector2:
	var u = 1.0 - t
	return u * u * a + 2.0 * u * t * ctrl + t * t * b

func _control_point(segment_index: int) -> Vector2:
	var a   = pin_centers[segment_index]
	var b   = pin_centers[segment_index + 1]
	var mid = (a + b) * 0.5
	# Alternate the curve bulge direction left/right for a winding feel
	var perp = (b - a).rotated(PI / 2.0).normalized()
	var bulge = 80.0 if segment_index % 2 == 0 else -80.0
	return mid + perp * bulge
