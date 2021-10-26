extends Spatial


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		body.in_water(true)


func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		body.in_water(false)
