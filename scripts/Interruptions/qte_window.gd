extends Panel

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

func start_qte(text: String, key: Key) -> void:
	hold_key = key
	instruction_label.text = text
	hint_label.text = "Hold %s" % OS.get_keycode_string(key)

	progress = 0.0
	remaining_grace = grace_time
	progress_bar.value = 0
	progress_bar.max_value = hold_time

	active = true
	show()

func _process(delta: float) -> void:
	if not active:
		return

	# Update progress
	if Input.is_key_pressed(hold_key):
		progress += delta
	else:
		remaining_grace -= delta

	# Clamp values
	progress = clamp(progress, 0, hold_time)
	remaining_grace = max(0, remaining_grace)
	progress_bar.value = progress

	# Only finish once
	if progress >= hold_time and active:
		_finish(true)
	elif remaining_grace <= 0 and active:
		_finish(false)

func _finish(success: bool) -> void:
	if not active:
		return  # prevent double finish
	active = false
	hide()
	emit_signal("qte_finished", success)
