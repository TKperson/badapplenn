extends Interactable

class_name Board

signal update_board(uv_coordinate)

signal reset_cursor_coordinate()

#func draw(uv_coordinate):
	#emit_signal("update_board", uv_coordinate)

func interact(raycast: RayCast3D, collider):
	var uv_coordinate = Vector2(
		(raycast.get_collision_point().z - collider.global_position.z)
		/ collider.global_transform.basis.get_scale().x
		+ 0.5
		,
		(raycast.get_collision_point().y - collider.global_position.y)
		/ collider.global_transform.basis.get_scale().y
		+ 0.5
	)
	
	emit_signal("update_board", uv_coordinate)

func released():
	emit_signal("reset_cursor_coordinate")
