extends Panel

const QTEKey = preload("res://scripts/Managers/qte_key.gd")

signal qte_finished(success: bool)

@export var max_hold_time: float = 3.0     # max seconds per key
@export var grace_duration: float = 0.5    # seconds to allow wrong key presses

@onready var instruction_label: Label = $VBoxContainer/InstructionsLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/EventProgressbar
@onready var hint_label: Label = $VBoxContainer/HintLabel
@onready var key_container: HBoxContainer = $VBoxContainer/KeyContainer

var active := false
var qte_sequence: Array[QTEKey] = []
var current_index := 0
var current_progress := 0.0
var current_elapsed := 0.0
var grace_timer := 0.0

# === Start a new QTE sequence ===
func start_qte(text: String, keys: Array[QTEKey]) -> void:
	instruction_label.text = text
	qte_sequence = keys
	current_index = 0
	current_progress = 0.0
	current_elapsed = 0.0
	grace_timer = 0.0
	
	for child in key_container.get_children():
		child.queue_free()
	
	for key_obj in qte_sequence:
		var lbl = Label.new()
		lbl.text = _get_key_name(key_obj.keycode)
		lbl.add_theme_color_override("font_color", Color(0.8,0.8,0.8))
		key_container.add_child(lbl)
		
	_update_highlighted_key()

	progress_bar.value = 0
	progress_bar.max_value = qte_sequence[0].hold_time
	hint_label.text = "Hold: %s" % _get_key_name(qte_sequence[0].keycode)

	active = true
	show()

# === Per-frame update ===
func _process(delta: float) -> void:
	if not active:
		return

	var current_key = qte_sequence[current_index]

	# Update elapsed time for this key
	current_elapsed += delta

	# Fail if max hold time exceeded
	if current_elapsed > max_hold_time:
		_finish(false)
		return

	# Countdown grace timer
	if grace_timer > 0:
		grace_timer -= delta
		if grace_timer <= 0:
			_finish(false)
			return

	# Update progress for holding the correct key
	if Input.is_key_pressed(current_key.keycode):
		current_progress += delta
		grace_timer = 0  # pressing correct key cancels any grace timer
	else:
		current_progress -= delta  # decay if not holding

	# Clamp progress
	current_progress = clamp(current_progress, 0, current_key.hold_time)
	progress_bar.value = current_progress

	# Check if current key completed
	if current_progress >= current_key.hold_time:
		current_index += 1
		_update_highlighted_key()
		if current_index >= qte_sequence.size():
			_finish(true)
			return
		# Reset for next key
		current_progress = 0
		current_elapsed = 0
		grace_timer = 0
		progress_bar.max_value = qte_sequence[current_index].hold_time
		progress_bar.value = 0
		hint_label.text = "Hold: %s" % _get_key_name(qte_sequence[current_index].keycode)

# === Handle key presses (fail on wrong, with grace) ===
func _input(event: InputEvent) -> void:
	if not active:
		return

	if event is InputEventKey and event.pressed:
		var current_key = qte_sequence[current_index]

		if event.keycode != current_key.keycode:
			grace_timer = grace_duration  # start grace timer on wrong key

# === Helper to show key name in hint label ===
func _get_key_name(keycode: int) -> String:
	match keycode:
		KEY_Z: return "Z"
		KEY_X: return "X"
		KEY_C: return "C"
		KEY_UP: return "UP"
		KEY_DOWN: return "DOWN"
		KEY_LEFT: return "LEFT"
		KEY_RIGHT: return "RIGHT"
		_: return str(keycode)

# === Finish QTE sequence ===
func _finish(success: bool) -> void:
	if not active:
		return

	active = false
	hide()
	emit_signal("qte_finished", success)
	
func _update_highlighted_key() -> void:
	for i in range(key_container.get_child_count()):
		var lbl = key_container.get_child(i)
		if i < current_index:
			lbl.add_theme_color_override("font_color", Color(0,0.6, 1))
		elif i == current_index:
			lbl.add_theme_color_override("font_color", Color(0,1,0))
		else:
			lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
