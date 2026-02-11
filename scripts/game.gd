extends Node2D

const QTEKey = preload("res://scripts/Managers/qte_key.gd")

# === Node references ===
@onready var qte_window = $UI/QTEWindow
@onready var interruption_manager = $UI/InterruptionManager
#@onready var dog_window = $UI/InterruptionManager/DogInterruptWindow
#@onready var fail_panel = $UI/FailPanel
@onready var sleep_label: Label = $UI/PlayerUI/SleepScoreLabel
@onready var time_label: Label = $UI/PlayerUI/TimeLabel

var night_progress := 0

# Random number generator
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	update_time_and_flavour()
	rng.randomize()

	# Connect QTE signal
	qte_window.qte_finished.connect(_on_qte_finished)
	
	# Connect Interruption Manager
	interruption_manager.interruption_finished.connect(_on_interruption_finished)

	# Connect dog interruption signal (once)
	#dog_window.connect("interruption_finished", Callable(self, "_on_dog_finished"))
	
	# Connect toilet?

	# Connect SleepManager fail state signal
	SleepManager.connect("fail_state_triggered", Callable(self, "_on_fail_state"))

	# Connect SleepManager score change signal
	SleepManager.connect("score_changed", Callable(self, "_update_sleep_label"))

	# Initialize UI
	#fail_panel.hide()
	_update_sleep_label(SleepManager.sleep_score)

	# Start first sleep cycle
	start_sleep()

# === Sleep loop ===
func start_sleep() -> void:
	await get_tree().create_timer(1.0).timeout
	start_qte()

func start_qte() -> void:
	var qte_sequence: Array[QTEKey] = [
		QTEKey.new(KEY_Z, 1.0),
		QTEKey.new(KEY_X, 1.0),
		QTEKey.new(KEY_UP, 0.7),
		QTEKey.new(KEY_DOWN, 0.7)
	]
	
	qte_window.start_qte("Follow the sequence!", qte_sequence)

# === Event handlers ===
func _on_qte_finished(success: bool) -> void:
	if success:
		SleepManager.adjust_score(5)   # reward for success
		night_progress += 1
		update_time_and_flavour()
		start_sleep()
	else:
		SleepManager.adjust_score(-10) # penalty for failure
		if rng.randf() < 0.2 + night_progress * 0.05:
			interruption_manager.start_random_interruption(night_progress)
		else:
			start_sleep()

#func _on_dog_finished() -> void:
#	dog_window.hide()
#	SleepManager.adjust_score(5)  # reward for completing dog interrupt
#	start_sleep()

func _on_interruption_finished(success: bool):
	if success:
		SleepManager.adjust_score(5)
	else:
		SleepManager.adjust_score(-15)
		
	start_sleep()

# === Fail state ===
func _on_fail_state() -> void:
	print("You failed to sleep, now you have to spend the night pondering your choices")
	# Hide all active panels / stop the sleep loop
#	dog_window.hide()
#	qte_window.hide()
	#fail_panel.show()

# === UI updates ===
func _update_sleep_label(new_score: int) -> void:
	sleep_label.text = "Sleep: %d" % new_score
	
func get_current_time() -> String:
	var start_hour = 21
	var start_minute = 30
	var total_night_minutes = (7 * 60) + 60 # 10 hours = 600 minutes
	var max_steps = 20
	
	var minutes_per_step = total_night_minutes / max_steps
	var total_minutes_elapsed = int(night_progress * minutes_per_step)
	
	var hour = start_hour + int((start_minute + total_minutes_elapsed) / 60)
	var minute = (start_minute + total_minutes_elapsed) % 60
	
	var period = "AM"
	if hour >= 24:
		hour -= 24
	if hour >= 12:
		period = "PM"
		if hour > 12:
			hour -= 12
	if hour == 0:
		hour = 12
		
	return "%02d:%02d %s" % [hour, minute, period]
	
func get_flavour_text() -> String:
	if night_progress <= 5:
		return "The night is quiet."
	elif night_progress <= 15:
		return "The house feels restless."
	else:
		return "Every creak keeps you awake."
		
func update_time_and_flavour():
	time_label.text = "%s\n%s" % [get_current_time(), get_flavour_text()]
