extends Node

class_name QTEKey

var keycode: int
var hold_time: float
var release_window: bool = false  # For future release windows

func _init(keycode: int = KEY_Z, hold_time: float = 1.0, release_window: bool = false):
	self.keycode = keycode
	self.hold_time = hold_time
	self.release_window = release_window
