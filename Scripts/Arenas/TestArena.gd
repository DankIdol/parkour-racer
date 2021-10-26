extends Spatial

func _process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
