extends Node
class_name NightManager

const MAX_NIGHT_STEPS = 20
const MAX_TENSION = 1.0
const BASE_TENSION_GAIN = 0.25

var current_night = 1
var night_progress = 0
var tension = 0.0

var modifiers = {
	"qte_speed_multiplier": 1.0,
	"tension_gain_multiplier": 1.0
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
		tension + BASE_TENSION_GAIN * modifiers.tension_gain_multiplier,
		0,
		MAX_TENSION
	)

func should_trigger_interruption(base_chance: float, difficulty_level: int, rng: RandomNumberGenerator) -> bool:
	var chance = base_chance + night_progress * 0.05 + (difficulty_level - 1) * 0.05
	if tension >= MAX_TENSION:
		tension = 0
		return true
	if rng.randf() < chance:
		tension = 0
		return true
	return false

func scale_difficulty():
	modifiers.qte_speed_multiplier = clamp(modifiers.qte_speed_multiplier * 0.95, 0.6, 1.0)
	modifiers.tension_gain_multiplier = clamp(modifiers.tension_gain_multiplier * 1.05, 1.0, 2.0)
	current_night += 1
