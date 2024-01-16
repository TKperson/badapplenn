extends Interactable

class_name SubmitButton

signal submit()

func interact(_raycast: RayCast3D, _collider):
	emit_signal("submit")
