extends Panel

const QTEKey = preload("res://scripts/Managers/qte_key.gd")

signal qte_finished(success: bool)

@export var hold_key: Key = KEY_Z
@export var hold_time: float = 2.0
@export var grace_time: float = 1.5

@onready var instruction_label: Label = $VBoxContainer/InstructionsLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/EventProgressbar
@onready var hint_label: Label = $VBoxContainer/HintLabel

var progress := 0.0
var remaining_grace := 0.0
var active := false

var qte_sequence: Array[QTEKey] = []
var current_index := 0
var current_progress := 0.0

var grace_timer := 0.0
var grace_duration := 0.5

# === Start a new QTE sequence ===
func start_qte(text: String, keys: Array[QTEKey]) -> void:
	instruction_label.text = text
	qte_sequence = keys
	current_index = 0
	current_progress = 0.0
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

	# Check if the correct key is being held
	if Input.is_key_pressed(current_key.keycode):
		current_progress += delta
	else: 
		current_progress -= delta # decay if not holding

	# Clamp progress
	current_progress = clamp(current_progress, 0, current_key.hold_time)
	progress_bar.value = current_progress
	
	# Check if current key is completed
	if current_progress >= current_key.hold_time:
		current_index += 1
		if current_index >= qte_sequence.size():
			_finish(true)
			return
		# Reset progress for next key
		current_progress = 0
		progress_bar.max_value = qte_sequence[current_index].hold_time
		hint_label.text = "Hold: %s" % _get_key_name(qte_sequence[current_index].keycode)
		
		grace_timer = grace_duration
		
		if grace_timer > 0:
			grace_timer -= delta
		else:
			if not Input.is_key_pressed(current_key.keycode):
				current_progress -= delta

# === Handle key presses (sequential and fail-on-wrong) ===
func _input(event: InputEvent) -> void:
	if not active:
		return

	if event is InputEventKey and event.pressed:
		var current_key = qte_sequence[current_index]
		
		if current_progress < current_key.hold_time:
			if event.keycode == current_key.keycode:
				current_progress += 0.05
				current_progress = clamp(current_progress, 0, current_key.hold_time)
			elif grace_timer <= 0:
				_finish(false)
			
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

# === Finish QTE ===
func _finish(success: bool) -> void:
	if not active:
		return  # prevent double finish
	active = false
	hide()
	emit_signal("qte_finished", success)
