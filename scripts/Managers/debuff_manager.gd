extends Node

var possible_debuffs := [
	{
		"name": "Longer Hold",
		"hold_time_multiplier": 1.2,
		"decay_mulitplier": 1.0
	},
	{
		"name": "Faster Decay",
		"hold_time_multiplier": 1.0,
		"extra_time_buffer_multiplier": 1.0,
		"decay_multiplier": 1.3
	},
	{
		"name": "Smaller Buffer",
		"hold_time_multipler": 1.0,
		"extra_time_buffer_multiplier": 0.7,
		"decay_multiplier": 1.0
	},
	{
		"name": "Harder Circle",
		"hold_time_multiplier": 1.1,
		"extra_time_buffer_multiplier": 0.9,
		"decay_multiplier": 1.1
	}
]

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
func get_random_debuffs(num_debuffs: int = 1) -> Array:
	var selected := []
	var pool := possible_debuffs.duplicate()
	for i in range(num_debuffs):
		if pool.size() == 0:
			break
		var debuff = pool.pick_random()
		selected.append(debuff)
		pool.erase(debuff)
	return selected
	
func combine_debuffs(debuffs: Array) -> Dictionary:
	var result = {
		"hold_time_multiplier": 1.0,
		"extra_time_buffer_multiplier": 1.0,
		"decay_multiplier": 1.0,
		"names": []
	}
	for d in debuffs:
		result["hold_time_multiplier"] *= d.get("hold_time_multiplier", 1.0)
		result["extra_time_buffer_multiplier"] *= d.get("extra_time_buffer_multiplier", 1.0)
		result["decay_multiplier"] *= d.get("decay_multiplier", 1.0)
		result["names"].append(d.get("name", "Unknown"))
	return result
