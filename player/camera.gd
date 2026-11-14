extends Camera2D

func _process(delta: float) -> void:
	var center_x: float = get_screen_center_position().x
	var half_width: float = (get_viewport_rect().size.x / zoom.x) * 0.5
	var left_screen_edge: float = center_x - half_width
	
	limit_left = int(maxf(limit_left, left_screen_edge))
