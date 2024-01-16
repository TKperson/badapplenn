extends Interactable

class_name ClearButton

signal clear_board()

func interact(_raycast: RayCast3D, _collider):
	emit_signal("clear_board")
