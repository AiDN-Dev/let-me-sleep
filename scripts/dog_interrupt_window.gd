extends Panel

signal interruption_finished

@onready var dog = $Dog

func start_interruption():
	show()
	dog.position = Vector2(50, 50)
	dog.connect("drag_finished", Callable(self, "_finish"), CONNECT_ONE_SHOT)

func _finish():
	hide()
	emit_signal("interruption_finished")
