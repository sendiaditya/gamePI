extends CharacterBody3D

var player = null
var spawn = null
var state_machine
var health = 20

var SPEED = 4.0
const ATTACK_RANGE = 2.0
var DAMAGE = 20


signal miniboss_hit
signal miniboss_defeated

@export var player_path := "/root/World/map/NavigationRegion3D/player"
@export var spawn_path := "/root/World"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	spawn = get_node(spawn_path)
	state_machine = anim_tree.get("parameters/playback")
	
	var settings = Global.get_settings_for("miniboss")
	health = settings["health"]
	DAMAGE = settings["damage"]
	SPEED = settings["speed"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Walk":
			# Navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
			#look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP, true)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	
	
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	anim_tree.get("parameters/playback")
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE


func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir, DAMAGE)


func _on_area_3d_body_part_hit(dam):
	health -= dam
	emit_signal("miniboss_hit")
	if health <= 0:
		emit_signal("miniboss_defeated")
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()
		spawn.died()
		player.update()
