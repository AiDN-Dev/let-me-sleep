extends Node
class_name NightStats

var qte_successes: int = 0
var qte_failures: int = 0
var interruptions_triggered: int = 0
var interruptions_successful: int = 0
var interruptions_failed: int = 0

func _reset():
	qte_successes = 0
	qte_failures = 0
	interruptions_triggered = 0
	interruptions_successful = 0
	interruptions_failed = 0
