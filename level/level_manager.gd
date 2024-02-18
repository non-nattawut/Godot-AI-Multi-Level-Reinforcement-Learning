extends Node3D

@export var player : CharacterBody3D
@export var camera : Camera3D
@export var current_level = 0 # 0 mean level 1
@export var level_node : Array[Node3D]

func _ready():
	player.goal_reached.connect(_end_level)
	camera.position = get_current_level().get_camera_global_position()

func get_current_level() -> Node3D:
	return level_node[current_level]

func _end_level():
	if get_current_level().is_last_level: # if reached goal and that goal is last level
		current_level = 0
	else : current_level += 1
	
	for i in range(0,100): # make camera smooth
		await get_tree().create_timer(0.02).timeout
		camera.global_position = camera.global_position.slerp(level_node[current_level].get_camera_global_position(), 0.1)
		#camera.global_position = level_node[current_level].get_camera_global_position()
