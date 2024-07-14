extends Node3D

@onready var hit_rect = $Control/ColorRect
@onready var spawns = $map/spawner
@onready var navigation_region = $map/NavigationRegion3D

@onready var crosshair = $Control/crosshair
@onready var crosshairhit = $Control/crosshairhit

var zombie = load("res://models/keroco/keroco.tscn")
var instance
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	crosshair.position.x = get_viewport().size.x / 2 - 36 
	crosshair.position.y = get_viewport().size.y / 2 - 36  
	crosshairhit.position.x = get_viewport().size.x / 2 - 36
	crosshairhit.position.y = get_viewport().size.y / 2 - 36 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_player_player_hit():
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

func _on_keroco_spawn_timer_timeout():
	var spawn_point = _get_random_child(spawns).global_position
	instance = zombie.instantiate()
	instance.position = spawn_point
	instance.keroco_hit.connect(_on_enemy_hit)
	navigation_region.add_child(instance)


func _on_enemy_hit():
	crosshairhit.visible = true
	await get_tree().create_timer(0.05).timeout
	crosshairhit.visible = false
