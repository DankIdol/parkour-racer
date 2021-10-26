extends Spatial

onready var box = $CSGCombiner/Box
onready var combiner = $CSGCombiner

onready var mats = [
	preload("res://Assets/Materials/Dark.tres"),
	preload("res://Assets/Materials/Green.tres"),
	preload("res://Assets/Materials/Purple.tres"),
	preload("res://Assets/Materials/Red.tres")
]

var start
var end
var finished = false

func _ready():
	randomize()
	
	for i in range(1000):
		var b = box.duplicate()
		b.material = mats[rand_range(0, 4)]
		b.width = rand_range(1, 15)
		b.height = rand_range(1, 15)
		b.depth = rand_range(1, 15)
		b.transform.origin = Vector3(rand_range(-50, 50), rand_range(-40, 40), rand_range(-1000, 0))
		combiner.add_child(b)

func _process(delta):
	if not finished:
		end = OS.get_unix_time()
		$Time.text = "Elapsed time: " + str( (end - start) ) + " s"
	else:
		$Time.text = "Final time: " + str( (end - start) ) + " s"
	
	if $FPS.global_transform.origin.z <= -490:
		finished = true
	if $FPS.global_transform.origin.y < -50:
		$FPS.global_transform.origin = Vector3(0, 2, 4)
		finished = false


func _on_VisibilityNotifier_camera_entered(camera):
	start = OS.get_unix_time()
