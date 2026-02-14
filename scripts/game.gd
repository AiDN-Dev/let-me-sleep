extends Node2D

const QTEKey = preload("res://scripts/Managers/qte_key.gd")
const NightStatsClass = preload("res://scripts/Managers/night_stats.gd")

# Node references
@onready var night_manager: NightManager = $NightManager
@onready var qte_window = $UI/QTEWindow
@onready var interruption_manager = $UI/InterruptionManager
@onready var sleep_label: Label = $UI/PlayerUI/SleepScoreLabel
@onready var time_label: Label = $UI/PlayerUI/TimeLabel
@onready var night_summary_panel: Panel = $UI/PlayerUI/NightSummaryPanel
@onready var night_title_label: Label = $UI/PlayerUI/NightSummaryPanel/TitleLabel
@onready var qte_success_label: Label = $UI/PlayerUI/NightSummaryPanel/QTESuccessLabel
@onready var qte_fail_label: Label = $UI/PlayerUI/NightSummaryPanel/QTEFailLabel
@onready var interruptions_label: Label = $UI/PlayerUI/NightSummaryPanel/InterruptionsLabel
@onready var continue_button: Button = $UI/PlayerUI/NightSummaryPanel/ContinueButton

# Game state
var night_active = true
var possible_keys = [KEY_Z, KEY_X, KEY_C, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
var rng = RandomNumberGenerator.new()
var night_stats: NightStats

func _ready():
	rng.randomize()
	night_stats = NightStatsClass.new()
	# Connect signals
	qte_window.qte_finished.connect(Callable(self, "_on_qte_finished"))
	interruption_manager.interruption_finished.connect(Callable(self, "_on_interruption_finished"))
	SleepManager.connect("fail_state_triggered", Callable(self, "_on_fail_state"))
	SleepManager.connect("score_changed", Callable(self, "_update_sleep_label"))
	continue_button.pressed.connect(Callable(self, "_on_continue_to_next_night"))
	_update_sleep_label(SleepManager.sleep_score)
	update_time_and_flavour()
	night_summary_panel.visible = false
	start_sleep()

# === Sleep / QTE loop ===
func start_sleep():
	await get_tree().create_timer(1).timeout
	start_qte()

func start_qte():
	var sequence = generate_qte_sequence(4)
	var debuffs = DebuffManager.get_random_debuffs(rng.randi_range(1, 2))
	var combined = DebuffManager.combine_debuffs(debuffs)
	
	var debuff_names = String(", ").join(combined["names"])
	qte_window.start_qte("Follow the sequence!", sequence)

# === QTE finished handler ===
func _on_qte_finished(success):
	if success:
		SleepManager.adjust_score(5)
		night_manager.advance_progress()
		night_manager.add_tension()
		night_stats.qte_successes += 1
	else: 
		SleepManager.adjust_score(-10)
		night_stats.qte_failures += 1
		night_manager.add_tension()
		
	if night_manager.is_night_complete():
		update_time_and_flavour()
		end_night()
		return
	
	update_time_and_flavour()
	
	if night_manager.should_trigger_interruption(rng):
		interruption_manager.start_random_interruption(night_manager.current_night)
	else:
		start_sleep()

# === Interruption finished handler ===
func _on_interruption_finished(success):
	night_stats.interruptions_triggered += 1
	if success:
		SleepManager.adjust_score(5)
		night_stats.interruptions_successful += 1
	else:
		SleepManager.adjust_score(-15)
		night_stats.interruptions_failed += 1
	start_sleep()

# === Fail state triggered by SleepManager ===
func _on_fail_state():
	print("You failed to sleep.")
	# fail_panel.show()

# === Night summary continue button ===
func _on_continue_to_next_night():
	night_summary_panel.visible = false
	start_new_night()

# === End of night ===
func end_night():
	night_active = false
	print("Night Complete! Sleep:", SleepManager.sleep_score)
	print("Stats - QTE Success:", night_stats.qte_successes, "Fail:", night_stats.qte_failures,
		"Interruptions:", night_stats.interruptions_triggered, "Success:", night_stats.interruptions_successful,
		"Fail:", night_stats.interruptions_failed)
	night_manager.advance_to_next_night()
	show_night_summary()

# === Start a new night ===
func start_new_night():
	print("Starting Night", night_manager.current_night)
	night_manager.reset_night()
	night_active = true
	night_stats._reset()
	SleepManager.sleep_score = 100
	_update_sleep_label(SleepManager.sleep_score)
	update_time_and_flavour()
	start_sleep()

# === Show night summary panel ===
func show_night_summary():
	qte_success_label.text = "QTE Successes: %d" % night_stats.qte_successes
	qte_fail_label.text = "QTE Failures: %d" % night_stats.qte_failures
	interruptions_label.text = "Interruptions: %d (Success: %d, Fail: %d)" % [
		night_stats.interruptions_triggered,
		night_stats.interruptions_successful,
		night_stats.interruptions_failed
	]
	night_summary_panel.visible = true

# === Generate a QTE sequence for the night ===
func generate_qte_sequence(length) -> Array[QTEKey]:
	var seq: Array[QTEKey] = []
	for i in range(length):
		var key = possible_keys[rng.randi_range(0, possible_keys.size() - 1)]
		var hold = 0.8 + rng.randf() * 0.7
		hold *= night_manager.active_qte_speed
		seq.append(QTEKey.new(key, hold))
	return seq

# === UI update helpers ===
func _update_sleep_label(score):
	sleep_label.text = "Sleep: %d" % score

func get_current_time():
	var start_min = 21 * 60 + 30
	var total = 600
	var step = total / night_manager.get_max_steps()
	var minutes = start_min + int(night_manager.night_progress * step)
	var h = int(minutes / 60) % 24
	var m = minutes % 60
	var period = "AM"
	if h >= 12:
		period = "PM"
		if h > 12:
			h -= 12
	elif h == 0:
		h = 12
	return "%02d:%02d %s" % [h, m, period]

func get_flavour_text():
	if night_manager.night_progress <= 5:
		return "The night is quiet."
	elif night_manager.night_progress <= 15:
		return "The house feels restless."
	else:
		return "Every creak keeps you awake."

func update_time_and_flavour():
	time_label.text = "%s\n%s" % [get_current_time(), get_flavour_text()]
