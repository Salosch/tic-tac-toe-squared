extends Node2D

@export var size := Vector2(16,16):
	set(value):
		size = value
		queue_redraw()

@onready var board := get_parent() as Board


func _draw():
	draw_rect(Rect2(0,0,size.x,size.y), Color(1,0,0,0.7), false, 2)


func _process(_delta):
	var grid_pos = board.global_to_map(get_viewport().get_mouse_position())
	var state = board.get_state(grid_pos)
	if state == board.empty_state and board.active:
		position = board.map_to_local(grid_pos) - size / 2
		show()
	else:
		hide()
