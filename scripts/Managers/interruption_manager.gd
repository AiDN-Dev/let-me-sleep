extends Node

signal interruption_finished

@onready var dialog_box: Panel = $"../PlayerUI/DialogBox"
# Add all mini-game nodes here
@onready var interruptions := [
	$DogInterruptWindow,
	$ToiletInterruptWindow,
	#$WaterInterruptWindow
]

var flavour_text := {
	"dog": [
		"This damn dog sleeping all over me...",
		"Why is he sideways again?",
		"I swear this dog gets bigger at night."
	],
	"toilet": [
		"Oh no. That feeling.",
		"This is not ideal timing at all...",
		"I should have gone before bed."
	],
	"water": [
		"My throat feels like sand.",
		"Why am i suddenly so thirsy?",
		"Did I drink anything today?"
	]
}

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	# Connect all interruption finished signals safely
	for panel in interruptions:
		if panel.has_signal("interruption_finished"):
			panel.connect("interruption_finished", Callable(self, "_on_interruption_finished"))
		else:
			print("Warning: panel ", panel.name, " has no 'interruption_finished' signal!")

	# Hide all panels at start
	for panel in interruptions:
		panel.hide()



# Call this to start a random interruption
func start_random_interruption(difficulty: int = 0):
	var panel = interruptions.pick_random()
	# Determine type of interuption
	var type = panel.interruption_type
	var text = flavour_text[type].pick_random()
	await dialog_box.show_text(text, 2.0)
	
	panel.start_interruption(difficulty)


func _on_interruption_finished(success: bool):
	emit_signal("interruption_finished", success)
