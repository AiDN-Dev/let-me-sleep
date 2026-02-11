extends Panel

@onready var label = $DialogBoxText

var typing := false
var skip_requested := false

func show_text(text: String, duration_after: float = 1.0):
	show()
	label.text = ""
	typing = true
	skip_requested = false

	await _type_text(text)

	typing = false
	
	# Small pause after text fully appears
	await get_tree().create_timer(duration_after).timeout
	hide()


func _type_text(full_text: String) -> void:
	for i in full_text.length():
		if skip_requested:
			label.text = full_text
			return

		label.text += full_text[i]
		await get_tree().create_timer(0.03).timeout


func _input(event):
	if typing and event.is_action_pressed("ui_accept"):
		skip_requested = true
