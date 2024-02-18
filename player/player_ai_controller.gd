extends AIController3D

# Stores the action sampled for the agent's policy, running in python
@onready var player = get_parent()
var move_direction : Vector3 = Vector3.ZERO

@onready var sensors: Array[Node] = $"../Sensors".get_children()

func _physics_process(_delta):
	n_steps += 1
	#print("n_step = ",n_steps, " reward = ",reward)
	if n_steps > reset_after:
		needs_reset = true
		done = true
		reward -= 2 # หากเวลาหมดจะถูก -2

func get_obs() -> Dictionary:
	var obs : Array = []
	
	var velocity: Vector3 = player.get_real_velocity().limit_length(20.0) / 20.0
	var self_position : Vector3 = player.global_position
	var start_position : Vector3 = player.level_manager.get_current_level().get_start_global_position()
	var goal_position : Vector3 = player.level_manager.get_current_level().get_goal_global_position()
	
	#print(player.level_manager.current_level)
	obs.append_array(
		[float(n_steps) / reset_after,
		velocity.x, velocity.y, velocity.z,
		#player.level_manager.current_level,
		#start_position.x, start_position.y, start_position.z,
		self_position.x, self_position.y, self_position.z,
		goal_position.x, goal_position.y, goal_position.z])
	obs.append_array(get_raycast_sensor_obs())

	return {"obs":obs}
	
func get_raycast_sensor_obs():
	var all_raycast_sensor_obs: Array[float] = []
	for raycast_sensor in sensors:
		all_raycast_sensor_obs.append_array(raycast_sensor.get_observation())
	return all_raycast_sensor_obs

func get_reward() -> float:
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"direction" : {
			"size": 2, # x and z axis
			"action_type": "continuous"
		},
		}
	
func set_action(action) -> void:
	move_direction = Vector3(
		clampf(action["direction"][0], -1.0, 1.0), # x axis
		0.0,
		clampf(action["direction"][1], -1.0, 1.0), # z axis
	).normalized()
