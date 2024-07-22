extends VBoxContainer

#const world = preload("res://world.tscn")
@onready var sound = $"../click"
@export var world_scene_path = "res://world.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process_(_delta):
	pass


func _on_start_pressed():
	sound.play()
	await get_tree().create_timer(0.09).timeout
	get_tree().change_scene_to_file("res://world.tscn")


func _on_quit_pressed():
	sound.play()
	await get_tree().create_timer(0.09).timeout
	get_tree().quit()


func _on_check_box_toggled(toggled_on):
	sound.play()
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_difficulty_item_selected(index):
	sound.play()
	Global.current_difficulty = index
