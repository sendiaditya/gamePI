extends VBoxContainer

#const world = preload("res://world.tscn")
@onready var sound = $"../click"
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


func _on_setting_pressed():
	sound.play()
