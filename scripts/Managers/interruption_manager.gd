extends Node

signal interruption_finished

# Add all mini-game nodes here
@onready var interruptions := [
	$DogInterruptWindow,
	#$ToiletInterruptWindow,
	#$WaterInterruptWindow
]

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	# Connect all interruption finished signals
	for panel in interruptions:
		panel.connect("interruption_finished", Callable(self, "_on_interruption_finished"))

	# Hide all panels at start
	for panel in interruptions:
		panel.hide()


# Call this to start a random interruption
func start_random_interruption():
	var panel = interruptions.pick_random()
	panel.show()
	if "start_interruption" in panel:
		panel.start_interruption()  # call specific mini-game start method if exists


func _on_interruption_finished():
	emit_signal("interruption_finished")
