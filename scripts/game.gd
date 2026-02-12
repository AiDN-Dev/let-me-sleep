extends Node2D

const QTEKey = preload("res://scripts/Managers/qte_key.gd")
const MAX_NIGHT_STEPS: int = 20
const MAX_TENSION: float = 1.0
const TENSION_GAIN_PER_SUCCESS: float = 0.25

# === Node references ===
@onready var qte_window = $UI/QTEWindow
@onready var interruption_manager = $UI/InterruptionManager
#@onready var dog_window = $UI/InterruptionManager/DogInterruptWindow
#@onready var fail_panel = $UI/FailPanel
@onready var sleep_label: Label = $UI/PlayerUI/SleepScoreLabel
@onready var time_label: Label = $UI/PlayerUI/TimeLabel

var night_progress := 0
var night_active: bool = true
var possible_keys := [KEY_Z, KEY_X, KEY_C, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
var rng := RandomNumberGenerator.new()
var difficulty_level: int = 1
var tension: float = 0.0
var current_night: int = 1

func _ready() -> void:
	update_time_and_flavour()
	rng.randomize()

	# Connect QTE signal
	qte_window.qte_finished.connect(Callable(self, "_on_qte_finished"))
	
	# Connect Interruption Manager
	interruption_manager.interruption_finished.connect(Callable(self, "_on_interruption_finished"))

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
	var qte_sequence: Array[QTEKey] = generate_qte_sequence(4)
	qte_window.start_qte("Follow the sequence!", qte_sequence)

# === Event handlers ===
func _on_qte_finished(success: bool) -> void:
	if success:
		SleepManager.adjust_score(5)   # reward for success
		night_progress += 1
		tension += TENSION_GAIN_PER_SUCCESS
		if night_progress >= MAX_NIGHT_STEPS:
			update_time_and_flavour()
			end_night()
			return
		update_time_and_flavour()
		if tension >= MAX_TENSION:
			tension = 0
			interruption_manager.start_random_interruption(difficulty_level)
		else:
			start_sleep()
	else:
		SleepManager.adjust_score(-10) # penalty for failure
		start_sleep()
		
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
	var start_minutes = (21 * 60) + 30 # 9:30PM in minutes
	var total_night_minutes = 600 # 10 hours
	var minutes_per_step = total_night_minutes / MAX_NIGHT_STEPS
	var current_total_minutes = start_minutes + int(night_progress * minutes_per_step)
	var hour = int(current_total_minutes / 60) % 24
	var minute = current_total_minutes % 60
	var period = "AM"
	if hour >= 12:
		period = "PM"
		if hour > 12:
			hour -= 12
	elif hour == 0:
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
	
func generate_qte_sequence(length: int) -> Array[QTEKey]:
	var sequence: Array[QTEKey] = []
	for i in range(length):
		var keycode = possible_keys[rng.randi_range(0, possible_keys.size() - 1)]
		var hold_time = 0.8 + rng.randf() * 0.7  # random hold between 0.8s and 1.5s
		sequence.append(QTEKey.new(keycode, hold_time))
	return sequence
	
func end_night() -> void:
	night_active = false
	print("Night Complete!")
	print("Final Sleep Score: ", SleepManager.sleep_score)
	
	difficulty_level += 1
	current_night += 1
	
	await get_tree().create_timer(2.0).timeout
	
	start_new_night()
	
func start_new_night() -> void:
	print("Starting Night ", current_night)
	
	night_progress = 0
	tension = 0
	night_active = true
	
	SleepManager.sleep_score = 100 
	_update_sleep_label(SleepManager.sleep_score)
	
	update_time_and_flavour()
	start_sleep()
