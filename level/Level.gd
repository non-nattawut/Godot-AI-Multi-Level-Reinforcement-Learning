extends Node3D

@export var start : Node3D
@export var goal : Node3D
var camera_position : Vector3 = Vector3(16, 16, position.z)


@export var is_last_level : bool = false

func get_start_global_position() -> Vector3:
	var rng = RandomNumberGenerator.new()
	var child_count = start.get_child_count()
	
	for i in start.get_children(): # make player not spawn at visible == false start node
		if not i.visible:
			child_count -= 1
	
	var start_node = rng.randi_range(0,child_count-1) # -1 because count 3 but index start at 0
	
	return start.get_child(start_node).global_position

func get_goal_global_position() -> Vector3:
	return goal.global_position
	
func get_camera_global_position() -> Vector3:
	return camera_position
