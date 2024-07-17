extends ColorRect

@onready var animation = $AnimationPlayer
@onready var exit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Quit
@onready var restart = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Restart

@onready var sound = $"../click"
const main_menu = preload("res://main_menu.tscn")
var crosshair
# Called when the node enters the scene tree for the first time.
func _ready():
	crosshair = get_tree().root.get_node("/root/World/Control/crosshair")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func unpause():
	animation.play("unpause")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if crosshair:
		crosshair.visible = true  # Make crosshair visible
	
func pause():
	animation.play("pause")
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if crosshair:
		crosshair.visible = false  # Hide crosshair



func _on_quit_pressed():
	sound.play()
	unpause()
	await get_tree().create_timer(0.09).timeout
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_packed(main_menu)
	#get_tree().quit()

func _on_restart_pressed():
	sound.play()
	unpause()
	await get_tree().create_timer(0.09).timeout
	get_tree().reload_current_scene()


func _on_resume_pressed():
	sound.play()
	unpause()
