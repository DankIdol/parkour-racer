extends Camera

var max_shake = 2

func shake():
	for i in range(3):
		var x = rand_range(-max_shake, max_shake)
		var y = rand_range(-max_shake, max_shake)
		var z = rand_range(-max_shake, max_shake)
		rotation_degrees = Vector3(x, y, z)
		yield(get_tree().create_timer(.05), "timeout")
	rotation_degrees = Vector3(0, 0, 0)
