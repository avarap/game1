extends Node

signal bootstrap_ready
signal day_changed(day: int)
signal time_changed(hour: int, minute: int)
signal save_completed(path: String)
signal load_completed(path: String)
signal debug_message(message: String)
