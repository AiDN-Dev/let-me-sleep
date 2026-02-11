extends ColorRect

signal drag_finished

@export var floor_node_path: NodePath
@onready var floor = get_node(floor_node_path)

var dragging := false
var drag_offset := Vector2.ZERO
var active := false

# --- Difficulty variables ---
var difficulty := 0
var pull_strength := 20.0
var max_time := 5.0
var elapsed := 0.0
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func start_dragging(new_difficulty: int = 0):
	position = Vector2(50,50)
	dragging = false
	active = true
	elapsed = 0.0

	difficulty = new_difficulty
	pull_strength = 20 + difficulty * 5
	max_time = max(1.5, 5.0 - difficulty * 0.2)

func _process(delta):
	if not active:
		return

	elapsed += delta

	# Only apply pull-back if player is NOT dragging
	if not dragging:
		if rng.randf() < 0.02 + difficulty * 0.01:
			position += Vector2(rng.randf_range(-1,1), rng.randf_range(-1,1)) * pull_strength * delta

	# Fail if time runs out
	if elapsed >= max_time:
		active = false
		emit_signal("drag_finished", false)

func _gui_input(event):
	if not active:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Check if mouse is inside the dog
			if Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position()):
				dragging = true
				drag_offset = position - get_local_mouse_position()
		else:
			if dragging:
				dragging = false
				check_completion()
	elif event is InputEventMouseMotion and dragging:
		position = get_local_mouse_position() + drag_offset

func check_completion() -> void:
	if not active:
		return  # already finished, ignore

	var dog_rect = Rect2(position, size)
	var floor_rect = Rect2(floor.position, floor.size)
	if dog_rect.intersects(floor_rect):
		print("Dog has met the floor should be finishing the mini-game")
		active = false
		dragging = false
		emit_signal("drag_finished", true)
