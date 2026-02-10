extends ColorRect

signal drag_finished

@export var floor_node_path: NodePath
@onready var floor = get_node(floor_node_path)

var dragging := false
var drag_offset := Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Check if mouse is inside the dog
			if Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position()):
				dragging = true
				drag_offset = position - get_local_mouse_position()
		else:
			if dragging:
				dragging = false
				check_completion()
	elif event is InputEventMouseMotion and dragging:
		position = get_local_mouse_position() + drag_offset

func check_completion() -> void:
	var dog_rect = Rect2(position, size)
	var floor_rect = Rect2(floor.position, floor.size)
	if dog_rect.intersects(floor_rect):
		emit_signal("drag_finished")
