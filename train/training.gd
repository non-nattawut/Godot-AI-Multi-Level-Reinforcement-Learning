extends Node3D


func _process(delta):
	var fps = Engine.get_frames_per_second()
	$CanvasLayer/Label.text = str(fps)
	
	if Input.is_action_just_pressed("ui_end"):
		get_tree().quit()
	
