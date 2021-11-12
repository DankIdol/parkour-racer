extends Spatial

func _ready():
	$AnimationPlayer.play("stand")
	
func _process(delta):
	if Input.is_action_just_pressed("slide"):
		$AnimationPlayer.play("wave")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "wave":
		$AnimationPlayer.play("stand")
