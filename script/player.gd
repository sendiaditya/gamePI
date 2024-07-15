extends CharacterBody3D


var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const HIT_STAGGER = 8.0

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

const MAX_HEALTH = 100
var health = MAX_HEALTH

signal player_hit
signal player_died


# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = 9.8

var bullet = load("res://models/pistol/bullet.tscn")
var bullet_trail = load("res://models/rifle/trail.tscn")
var instance

enum weapons {
	AUTO,
	PISTOLS
}
var weapon = weapons.AUTO
var can_shoot = true
@onready var weapon_switching = $head/Camera3D/WeaponSwitch

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var aim_ray = $head/Camera3D/aimRay
@onready var aim_ray_end = $head/Camera3D/aimRayEnd

@onready var gun_anim = $"head/Camera3D/Root Scene/RootNode/AnimationPlayer"
@onready var gun_barrel = $"head/Camera3D/Root Scene/RootNode/RayCast3D"
@onready var auto_anim = $head/Camera3D/rifle/AnimationPlayer
@onready var auto_barrel = $head/Camera3D/rifle/barrel
@onready var gun_anim2 = $"head/Camera3D/Root Scene2/RootNode/AnimationPlayer"
@onready var gun_barrel2 = $"head/Camera3D/Root Scene2/RootNode/RayCast3D"

@onready var health_bar = $head/Camera3D/Control/hp

@onready var pauseMenu =  $pause
@onready var deathMenu =  $death

var hit_rect

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	
	hit_rect = get_tree().root.get_node("/root/World/Control/ColorRect")

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	if event.is_action_pressed("esc"):
		pauseMenu.pause()

func _physics_process(delta): 

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("shift"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 8.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 8.0)
			#velocity.x = move_toward(velocity.x, 0, SPEED)
			#velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

		
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	
	# Shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		match weapon:
			weapons.AUTO:
				_shoot_auto()
			weapons.PISTOLS:
				_shoot_pistol()
	

			
	if Input.is_action_just_pressed("weapon_one") and weapon != weapons.AUTO:
		_raise_weapon(weapons.AUTO)
	if Input.is_action_just_pressed("weapon_two") and weapon != weapons.PISTOLS:
		_raise_weapon(weapons.PISTOLS)


	move_and_slide()



func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func hit(dir):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER
	
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
	
	decrease_health(10)

func decrease_health(amount):
	health -= amount
	health_bar.value = health
	if health <= 0:
		health = 0
		die()

func die():
	emit_signal("player_died")
	deathMenu.pause()

func _shoot_pistol():
	if !gun_anim.is_playing():
		gun_anim.play("shoot")
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		#instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
		if aim_ray.is_colliding():
			instance.set_velocity(aim_ray.get_collision_point())
		else:
			instance.set_velocity(aim_ray_end.global_position)
	if !gun_anim2.is_playing():
		gun_anim2.play("shoot")
		instance = bullet.instantiate()
		instance.position = gun_barrel2.global_position
		#instance.transform.basis = gun_barrel2.global_transform.basis
		get_parent().add_child(instance)
		if aim_ray.is_colliding():
			instance.set_velocity(aim_ray.get_collision_point())
		else:
			instance.set_velocity(aim_ray_end.global_position)
			
func _shoot_auto():
	if !auto_anim.is_playing():
			auto_anim.play("Shoot")
			instance = bullet_trail.instantiate()
			if aim_ray.is_colliding():
				instance.init(auto_barrel.global_position, aim_ray.get_collision_point())
				if aim_ray.get_collider().is_in_group("enemy"):
					aim_ray.get_collider().hit()
			else:
				instance.init(auto_barrel.global_position, aim_ray_end.global_position)
			get_parent().add_child(instance)
				
func _lower_weapon():
	match weapon:
		weapons.AUTO:
			weapon_switching.play("lowerRifle")
		weapons.PISTOLS:
			weapon_switching.play("lowerPistol")


func _raise_weapon(new_weapon):
	can_shoot = false
	_lower_weapon()
	await get_tree().create_timer(0.31).timeout
	match new_weapon:
		weapons.AUTO:
			weapon_switching.play_backwards("lowerRifle")
		weapons.PISTOLS:
			weapon_switching.play_backwards("lowerPistol")
	weapon = new_weapon
	can_shoot = true


