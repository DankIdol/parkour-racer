extends Control

onready var screen = get_viewport_rect().size
var artsize = Vector2(1920, 1080)
var movement = .1

func _ready():
	$Sprites.position = screen / 2
	$Sprites.scale = screen / artsize

func _process(delta):
	var mouse = get_global_mouse_position()
	var offset = mouse - screen / 2
	
	$Sprites/Assassinman.position = offset * movement * .1
	$Sprites/Partyman.position = offset * movement * .3
	$Sprites/Patchman.position = offset * movement * .5
