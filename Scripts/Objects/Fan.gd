extends Spatial

export var strength = 20

func _ready():
	$AnimationPlayer.play("rotate")

func _process(delta):
	for b in $Area.get_overlapping_bodies():
		if b.is_in_group("Player"):
			var vec = ($Target.global_transform.origin - global_transform.origin).normalized() * strength
			b.add_force(vec)

