extends Spatial

export (String, MULTILINE) var text

func _ready():
	$AnimationPlayer.play("default")
	$Label3D.text = text


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		visible = true


func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		visible = false
