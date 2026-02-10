extends Node

var sleep_score: int = 100
var max_score: int = 100

signal score_changed(new_score)
signal fail_state_triggered()

func reset_score():
	sleep_score = max_score
	emit_signal("score_changed", sleep_score)
	
func adjust_score(ammount: int) -> void:
	sleep_score += ammount
	sleep_score = clamp(sleep_score, 0, max_score)
	emit_signal("score_changed", sleep_score)
	
	if sleep_score <= 0:
		emit_signal("fail_state_triggered")
