#@tool
extends Node3D

@export var size: float = 0.05
@export var padding: float = 1

@onready var http_request = $HTTPRequest
@onready var labels = $labels
@onready var timer = $Timer

const OUTPUT_PARAM = preload("res://scenes/dnn/output_param.tscn")
const LAYER = preload("res://scenes/dnn/layer.tscn")

var structure: Array = []
var all_params: Array = []
var all_materials: Array = []

func _ready():
	print('requesting for model structure')
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("http://127.0.0.1:5000/shapes")
	
	transform.scaled(Vector3(size, size, 1))
	
	for i in range(2**8):
		var material = StandardMaterial3D.new()
		var intensity = i / 255.0
		material.albedo_color = Color(intensity, intensity, intensity)
		all_materials.append(material)
	
func _on_request_completed(_result, response_code, _headers, body):
	print("done")
	if response_code == 0:
		print("unable to connect to backend server")
		get_tree().quit()
		return
	structure = bytes_to_var(body)
	print(structure)
	
	generate_structure()
	
func generate_structure():
	for i in range(structure.size()):
		var layer = LAYER.instantiate()
		for y in range(structure[i].y - 1, -1, -1):
			for x in range(structure[i].x - 1, -1, -1):
				var param = OUTPUT_PARAM.instantiate()
				param.scale = Vector3(size, size, size)
				param.translate(Vector3(
					x * (1 + padding) - structure[i].x / 2 - padding * structure[i].x / 2,
					y * (1 + padding) - structure[i].y / 2 - padding * structure[i].y / 2,
					i * 150
				))
				all_params.append(param.get_child(0))
				layer.add_child(param)
		add_child(layer)
		
func update_params(param_data):
	var total_length = all_params.size()
	for i in range(total_length):
		all_params[i].material_override = all_materials[param_data[i]]
		
	# labels
	for i in range(10):
		labels.labels[i].set_material(all_params[total_length -  10 + i].material_override)

func play_badapple(all_frames):
	var total_frames = 81 * 81
	var frame_size = all_params.size()
	timer.start()
	for i in range(total_frames):
		update_params(
			all_frames.slice(i * frame_size, (i + 1) * frame_size)
		)
		
		# 30 frames per second
		# godot timeout is not doing 1/30 :skull:
		await timer.timeout
		
	timer.stop()
