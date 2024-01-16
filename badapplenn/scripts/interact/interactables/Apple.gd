extends Interactable

class_name Apple

signal set_apple_animation(state: bool)

@onready var apple = $".."
@onready var http_request = $"../HTTPRequest"
@onready var neural_net = $"../../../neural net"

func _ready():
	http_request.request_completed.connect(_on_request_completed)
	http_request.download_chunk_size = 2**24
	

func interact(raycast: RayCast3D, _collider):
	apple.global_transform.origin = raycast.apple_position.global_position
	
	#apple.global_position = raycast.apple_position.global_position
	emit_signal("set_apple_animation", false)

var busy = false

func released():
	emit_signal("set_apple_animation", true)
	if busy:
		return
	busy = true
	
	http_request.request("http://127.0.0.1:5000/activations")
	
func _on_request_completed(_result, _response_code, _headers, body):
	print(body.size())
	busy = false
	neural_net.play_badapple(body)
