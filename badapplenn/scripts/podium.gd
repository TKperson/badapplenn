extends Node3D

@onready var animation_player = $AnimationPlayer

var apple_animation = true

func _on_area_3d_body_entered(body):
	animation_player.play("KeyAction")
	
	if apple_animation:
		await animation_player.animation_finished
		animation_player.play("apple_fadein")
	
func _on_area_3d_body_exited(body):
	if apple_animation:
		animation_player.play_backwards("apple_fadein")
		await animation_player.animation_finished
		
	animation_player.play_backwards("KeyAction")
	
func _on_static_body_3d_set_apple_animation(state):
	apple_animation = state
	
	if apple_animation:
		animation_player.play_backwards("apple_fadein")
