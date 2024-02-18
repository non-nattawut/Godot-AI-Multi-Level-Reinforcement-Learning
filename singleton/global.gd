extends Node

func game_win():
	get_tree().paused = true
	get_node("/root/Training/CanvasLayer/WinControl").visible = true
