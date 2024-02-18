extends CharacterBody3D

signal goal_reached()

@export var speed: float = 10.0
@export var rotation_speed: float = 15.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var player_visual = $Visual
@onready var ai_controller = $AIController3D
@export var level_manager : Node3D

func _ready():
	ai_controller.init(self)
	
	global_position = level_manager.get_current_level().get_start_global_position()

func _physics_process(delta):
	_need_reset()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var direction : Vector3 = Vector3.ZERO
	
	if ai_controller.heuristic == "human" :
		var input_dir = Input.get_vector("w", "s", "d", "a")
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	else :
		direction = ai_controller.move_direction
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	rotate_toward_movement(delta)
	move_and_slide()
	
	reward_by_distance()
	
func rotate_toward_movement(delta):
	var movement = Vector3(velocity.x, 0, velocity.z).normalized()
	var look_at_target: Vector3 = global_position + movement

	if look_at_target.distance_to(global_position) > 0:
		player_visual.global_transform = (
			player_visual
			. global_transform
			. interpolate_with(global_transform.looking_at(look_at_target), rotation_speed * delta)
			. orthonormalized()
		)

# ============================= AI Handle =============================
func _need_reset():
	if ai_controller.needs_reset:
		ai_controller.reset()
		_reset_player()
		return

# if level change player pos will at start node of that level
func _reset_player(): 
	latest_distance_to_goal = 0
	position = level_manager.get_current_level().get_start_global_position()
	
func _end_level(reward : float):
	ai_controller.reward += reward
	ai_controller.done = true
	ai_controller.needs_reset = true
	
	#var goal_position : Vector3 = level_manager.get_current_level().get_goal_global_position()
	#print_debug("goal pos = ",goal_position, " level = ",level_manager.current_level)

func _on_area_3d_area_entered(area):
	if area.get_collision_layer_value(2): # goal
		emit_signal("goal_reached")
		_end_level(1.0 + (1000 - ai_controller.n_steps)/1000.0) # ยิงเข้า goal เร็วยิ่งได้ reward เยอะ
		print("GOAL! = ",ai_controller.reward)
	if area.get_collision_layer_value(3): # deadzone
		_end_level(-3.0)
		#print("DIE! = ",ai_controller.reward)

func xz_distance(vector1: Vector3, vector2: Vector3):
	var vec1_xz := Vector2(vector1.x, vector1.z)
	var vec2_xz := Vector2(vector2.x, vector2.z)
	return vec1_xz.distance_to(vec2_xz) 

var latest_distance_to_goal = 0
func reward_by_distance():
	var goal_pos = level_manager.get_current_level().get_goal_global_position()
	var current_distance_to_goal = xz_distance(global_position, goal_pos)
	
	if not latest_distance_to_goal:
		latest_distance_to_goal = current_distance_to_goal
	
	#if current_distance_to_goal < latest_distance_to_goal: # ถ้าใช้ if นี้หมายถึงตำแหน่ง ล่าสุด player ระยะห่าง goal น้อยกว่าตำแหน่งก่อนหน้าที่ player ผ่านมา
	#print_debug("DISTANCE REWARD = ", (latest_distance_to_goal - current_distance_to_goal) / 10.0)
	
	# calculate reward, if player closer give positive reward, player more far give negative reward
	ai_controller.reward += (latest_distance_to_goal - current_distance_to_goal) / 10.0
	latest_distance_to_goal = current_distance_to_goal
