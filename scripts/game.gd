extends Node2D

@onready var qte_window = $UI/QTEWindow
@onready var dog_window = $UI/DogInterruptWindow

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	qte_window.connect("qte_finished", _on_qte_finished)
	start_sleep()
	
func start_sleep() -> void:
	await get_tree().create_timer(1.0).timeout
	start_qte()
	
func start_qte():
	var keys = [KEY_Z, KEY_X, KEY_C]
	var key = keys.pick_random()
	
	var texts = [
		"HOLD TO RELAX",
		"TRY TO SLEEP",
		"DO NOT WAKE UP",
		"IGNORE THE THOUGHTS"
	]
	
	qte_window.start_qte(texts.pick_random(), key)
	
func _on_qte_finished(success: bool) -> void:
	if success:
		start_sleep()
	else:
		# open dog interruption instead of restarting loop
		dog_window.start_interruption()
		dog_window.connect("interruption_finished", Callable(self, "_on_dog_finished"), CONNECT_ONE_SHOT)
		
func _on_dog_finished():
	dog_window.hide()
	start_sleep()
