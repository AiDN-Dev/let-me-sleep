extends Panel

signal interruption_finished(success: bool)

var interruption_type: String = "dog"

@onready var dog = $Dog

func _ready():
	dog.connect("drag_finished", Callable(self, "_on_dog_drag_finished"))
	hide()

func start_interruption(difficulty: int = 0):
	show()
	dog.start_dragging(difficulty)
	
func _on_dog_drag_finished(success: bool):
	_finish(success)

func _finish(success: bool):
	hide()
	emit_signal("interruption_finished", success)
