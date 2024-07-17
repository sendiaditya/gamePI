extends Node3D

@onready var hit_rect = $Control/ColorRect
@onready var spawns = $map/spawner
@onready var navigation_region = $map/NavigationRegion3D

@onready var crosshair = $Control/crosshair
@onready var crosshairhit = $Control/crosshairhit

@onready var portal = $"detail-plate2"
@onready var spawner = $KerocoSpawnTimer

@onready var st1 = $soundtrack1
@onready var st2 = $soundtrack2

var zombie = load("res://models/keroco/keroco.tscn")
var miniboss = load("res://models/minibos/miniboss.tscn")
var instance
var instanca

var miniboss_spawns = [
	Vector3(-31.028, 0, 138.669), # Replace with actual spawn positions
	Vector3(-10.504, 0, 21.491),
	Vector3(14.788, 0, 21.008)
]

var current_miniboss_spawn_index = 0
var miniboss_spawned = false
var miniboss_defeated = 0
var max_minibosses = 3
var miniboss_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	st1.play()
	randomize()
	crosshair.position.x = get_viewport().size.x / 2 - 36 
	crosshair.position.y = get_viewport().size.y / 2 - 36  
	crosshairhit.position.x = get_viewport().size.x / 2 - 36
	crosshairhit.position.y = get_viewport().size.y / 2 - 36 
	
	spawn_miniboss()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#print(miniboss_defeated, "and", )


func _on_player_player_hit():
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)

func _on_keroco_spawn_timer_timeout():
	if miniboss_defeated == max_minibosses:
		return # Don't spawn small enemies if minibosses beaten already 3
	var spawn_point = _get_random_child(spawns).global_position
	instance = zombie.instantiate()
	instance.position = spawn_point
	instance.keroco_hit.connect(_on_enemy_hit)
	navigation_region.add_child(instance)


func _on_enemy_hit():
	crosshairhit.visible = true
	await get_tree().create_timer(0.05).timeout
	crosshairhit.visible = false



func _on_miniboss_hit():
	crosshairhit.visible = true
	await get_tree().create_timer(0.05).timeout
	crosshairhit.visible = false
	
#func _on_boss_hit():
	#crosshairhit.visible = true
	#await get_tree().create_timer(0.05).timeout
	#crosshairhit.visible = false


func died():
	miniboss_defeated += 1
	miniboss_count += 1
	miniboss_spawned = false
	if miniboss_defeated<3:
		spawn_miniboss()
	else:
		spawns.queue_free()
		portal.queue_free()
		spawner.queue_free()
		print("All minibosses defeated. Small enemies will stop spawning and the red gate dissapear.")
		
func changesong():
	st1.stop()
	st2.play()

func spawn_miniboss():
	var spawn_point = miniboss_spawns[miniboss_count]
	#var spawn_point = Vector3(-31.028, 0, 138.669)
	instanca = miniboss.instantiate()
	instanca.position = spawn_point
	instanca.miniboss_hit.connect(_on_miniboss_hit)
	navigation_region.add_child(instanca)
	miniboss_spawned = true




func _on_bos_boss_hit():
	crosshairhit.visible = true
	await get_tree().create_timer(0.05).timeout
	crosshairhit.visible = false
