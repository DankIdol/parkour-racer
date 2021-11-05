extends Spatial

export (String, MULTILINE) var text

func _ready():
	$Label3D.text = text
