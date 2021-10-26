extends Spatial



func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		body.gravity  = -5

func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		body.gravity  = 9.8
