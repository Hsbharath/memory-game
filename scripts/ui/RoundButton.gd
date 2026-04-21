extends Button

@onready var round_label: Label = $VBoxContainer/RoundLabel
@onready var star1: Label = $VBoxContainer/StarsContainer/Star1
@onready var star2: Label = $VBoxContainer/StarsContainer/Star2
@onready var star3: Label = $VBoxContainer/StarsContainer/Star3
@onready var lock_label: Label = $VBoxContainer/LockLabel

func setup(round_number: int, stars: int, is_unlocked: bool) -> void:
	round_label.text = "Round %d" % round_number
	lock_label.visible = not is_unlocked
	disabled = not is_unlocked
	modulate = Color.WHITE if is_unlocked else Color(0.5, 0.5, 0.5)

	var star_nodes = [star1, star2, star3]
	for i in 3:
		star_nodes[i].modulate = Color.YELLOW if i < stars else Color(0.3, 0.3, 0.3)
