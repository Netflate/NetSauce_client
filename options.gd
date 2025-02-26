extends Control



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		Global.play_sound(Global.exit_sound)
		get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		2:
			DisplayServer.window_set_size(Vector2i(1280, 720))
	
