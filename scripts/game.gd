extends Node2D

# === Node references ===
@onready var qte_window = $UI/QTEWindow
@onready var interruption_manager = $UI/InterruptionManager
@onready var dog_window = $UI/InterruptionManager/DogInterruptWindow
#@onready var fail_panel = $UI/FailPanel
@onready var sleep_label = $UI/SleepScoreLabel

# Random number generator
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

	# Connect QTE signal
	qte_window.connect("qte_finished", Callable(self, "_on_qte_finished"))
	
	# Connect Interruption Manager
	interruption_manager.connect("interruption_finished", Callable(self, "_on_interruption_finished"))

	# Connect dog interruption signal (once)
	dog_window.connect("interruption_finished", Callable(self, "_on_dog_finished"))

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
	var keys = [KEY_Z, KEY_X, KEY_C]
	var key = keys.pick_random()

	var texts = [
		"HOLD TO RELAX",
		"TRY TO SLEEP",
		"DO NOT WAKE UP",
		"IGNORE THE THOUGHTS"
	]

	qte_window.start_qte(texts.pick_random(), key)

# === Event handlers ===
func _on_qte_finished(success: bool) -> void:
	if success:
		SleepManager.adjust_score(5)   # reward for success
		start_sleep()
	else:
		SleepManager.adjust_score(-10) # penalty for failure
		interruption_manager.start_random_interruption()

func _on_dog_finished() -> void:
	dog_window.hide()
	SleepManager.adjust_score(5)  # reward for completing dog interrupt
	start_sleep()

func _on_interruption_finished():
	print("Intteruption finished")

# === Fail state ===
func _on_fail_state() -> void:
	print("You failed to sleep, now you have to spend the night pondering your choices")
	# Hide all active panels / stop the sleep loop
	dog_window.hide()
	qte_window.hide()
	#fail_panel.show()

# === UI updates ===
func _update_sleep_label(new_score: int) -> void:
	sleep_label.text = "Sleep: %d" % new_score
