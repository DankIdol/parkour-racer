extends RigidBody

func _ready():
	pass

func grab():
	mode = RigidBody.MODE_STATIC

func _on_Timer_timeout():
	queue_free()
