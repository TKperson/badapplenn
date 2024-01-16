extends RayCast3D

var current_collider: Interactable
var last_interactable
@onready var apple_position = $"../apple_position"

func _process(_delta):
	var collider = get_collider()
	
	if is_colliding() and collider is Interactable:
		if current_collider != collider:
			current_collider = collider 
		last_interactable = collider
		
		if Input.is_action_pressed("interact"):
			
			collider.interact(self, collider)
				
	elif current_collider:
		current_collider = null
		
	if last_interactable and Input.is_action_just_released("interact"):
		last_interactable.released()
		
		
