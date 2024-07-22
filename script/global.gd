extends Node

# Enum for difficulty levels
enum Difficulty { EASY, NORMAL, HARD }

# Default difficulty level
var current_difficulty = Difficulty.EASY

# Difficulty settings
var settings = {
	Difficulty.EASY: { "keroco": {"health": 6, "damage": 20, "speed": 4.0, "spawn_time": 5.0}, "miniboss": {"health": 20, "damage": 20, "speed": 4.0}, "boss": {"health": 50, "damage": 40, "speed": 10.0}},
	Difficulty.NORMAL: { "keroco": {"health": 12, "damage": 25, "speed": 5.0, "spawn_time": 4.0}, "miniboss": {"health": 30, "damage": 25, "speed": 5.0}, "boss": {"health": 100, "damage": 50, "speed": 12.0}},
	Difficulty.HARD: { "keroco": {"health": 12, "damage": 30, "speed": 6.0, "spawn_time": 3.0}, "miniboss": {"health": 40, "damage": 30, "speed": 6.0}, "boss": {"health": 150, "damage": 90, "speed": 14.0}}
}

func get_settings_for(enemy_type: String) -> Dictionary:
	return settings[current_difficulty][enemy_type]

func get_keroco_spawn_time() -> float:
	return settings[current_difficulty]["keroco"]["spawn_time"]
