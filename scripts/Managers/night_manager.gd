extends Node
class_name NightManager

const MAX_NIGHT_STEPS = 20
const MAX_TENSION = 1.0
const BASE_TENSION_GAIN = 0.25

var current_night = 1
var night_progress = 0
var tension = 0.0

var active_qte_speed = 1.0
var active_tension_gain = 1.0
var active_base_interrupt_chance = 0.15

var modifiers = {
	"qte_speed_multiplier": 1.0,
	"tension_gain_multiplier": 1.0
}

var night_data = {
	1: {
		"qte_speed": 0.9,
		"tension_gain": 0.8,
		"base_interrupt_chance": 0.1
	},
	2: {
		"qte_speed": 0.95,
		"tension_gain": 0.9,
		"base_interrupt_chance": 0.15
	},
	3: {
		"qte_speed": 1.0,
		"tension_gain": 1.0,
		"base_interrupt_chance": 0.2
	},
	4: {
		"qte_speed": 1.05,
		"tension_gain": 1.1,
		"base_interrupt_chance": 0.25
	},
	5: {
		"qte_speed": 1.1,
		"tension_gain": 1.2,
		"base_interrupt_chance": 0.3
	},
	6: {
		"qte_speed": 1.05,
		"tension_gain": 1.1,
		"base_interrupt_chance": 0.25
	},
	7: {
		"qte_speed": 1.2,
		"tension_gain": 1.5,
		"base_interrupt_chance": 0.4
	}
}

func reset_night():
	night_progress = 0
	tension = 0.0

func advance_progress():
	night_progress += 1

func is_night_complete():
	return night_progress >= MAX_NIGHT_STEPS

func add_tension():
	tension = clamp(
		tension + BASE_TENSION_GAIN * active_tension_gain,
		0,
		MAX_TENSION
	)

func should_trigger_interruption(rng: RandomNumberGenerator) -> bool:
	var chance = active_base_interrupt_chance + night_progress * 0.03
	if tension >= MAX_TENSION:
		tension = 0
		return true
	if rng.randf() < chance:
		tension = 0
		return true
	return false

func advance_to_next_night():
	current_night += 1
	apply_night_settings()

func get_max_steps():
	return MAX_NIGHT_STEPS

func apply_night_settings():
	if night_data.has(current_night):
		var data = night_data[current_night]
		active_qte_speed = data.qte_speed
		active_tension_gain = data.tension_gain
		active_base_interrupt_chance = data.base_interrupt_chance
	else:
		active_qte_speed = max(active_qte_speed * 0.97, 0.5)
		active_tension_gain *= 1.05
		active_base_interrupt_chance = min(active_base_interrupt_chance * 1.02, 0.9)
