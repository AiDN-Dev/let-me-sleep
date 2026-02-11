extends Panel

signal interruption_finished(success: bool)

@onready var progress_bar: ProgressBar = $ReleifMeter
@export var required_progress: float = 20.0  # Progress to reach
@export var max_time: float = 5.0            # Time limit in seconds

var interruption_type: String = "toilet"
var progress := 0.0
var active := false
var elapsed := 0.0

# Difficulty variables
var difficulty := 0  # night_progress
var progress_per_press := 1.0
var decay_speed := 0.5  # Progress lost per second

func start_interruption(new_difficulty: int = 0):
	difficulty = new_difficulty
	progress = 0.0
	elapsed = 0.0
	active = true
	show()

	# --- Player effectiveness: decreases slightly as difficulty rises ---
	progress_per_press = max(0.3, 1.5 - difficulty * 0.05)

	# --- Bar fights back: decay speed increases with difficulty ---
	decay_speed = min(2.0, 0.3 + difficulty * 0.08)

	# --- Max time decreases slightly as difficulty rises ---
	max_time = max(2.5, 5.0 - difficulty * 0.1)

	progress_bar.max_value = required_progress
	progress_bar.value = progress

func _process(delta: float):
	if not active:
		return

	elapsed += delta

	# The bar fights back
	progress -= decay_speed * delta
	progress = clamp(progress, 0, required_progress)
	progress_bar.value = progress

	# Fail if time runs out
	if elapsed >= max_time:
		_finish(false)

func _input(event: InputEvent):
	if not active:
		return

	# Mash with SPACE
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		progress += progress_per_press
		progress = clamp(progress, 0, required_progress)
		progress_bar.value = progress

		if progress >= required_progress:
			_finish(true)

func _finish(success: bool):
	if not active:
		return
	active = false
	hide()
	emit_signal("interruption_finished", success)
