@tool
extends Node3D

@export_category("Painting panel")
@export_range(0, 100, 1) var resolution: int = 16
@export_range(0, 1, 0.01) var margin: float = 0.1

const PIXEL = preload("res://scenes/painting/pixel.tscn")
@onready var wall = $board
@onready var panel = $board/panel
@onready var neural_net = $"../neural net"

var pixels: Array = []
var pixel_values: Array = []
var all_materials: Array = []

func set_pixel_color(pixel: MeshInstance3D, intensity: float):
	var child: MeshInstance3D = pixel.get_child(0)
	child.material_override = all_materials[floor(intensity * 255)]

func set_pixel_value(pixel_coordinate: Vector2, intensity: float):	
	if intensity >= 2**(10 - 8):
		intensity = 2**(10 - 8) - 1/255
		
	var pixel = pixels[pixel_coordinate.x][pixel_coordinate.y]
	set_pixel_color(pixel, intensity)
	pixel_values[resolution - pixel_coordinate.y - 1][resolution - pixel_coordinate.x - 1] = intensity
	
func clear_board(fill_value: float = 0.0):
	for y in range(resolution):
		for x in range(resolution):
			set_pixel_value(Vector2(x, y), fill_value)
	
func _ready():
	var pixel_size = 1.0 / resolution
	var offset = Vector2(resolution / 2.0 - 0.5, resolution / 2.0 - 0.5)
	for i in range(2**10):
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(i / 255, i / 255, i / 255)
		all_materials.append(material)
	
	panel.scale = Vector3(1.0 - 2 * margin, 1.0 - 2 * margin, wall.scale.z)
	panel.position.z = -0.1
	
	for x in range(resolution):
		var coordinate = Vector2(x, 0)
		var row = []
		var pixel_values_row = []
		for y in range(resolution):
			var pixel = PIXEL.instantiate()
			pixel.scale = Vector3(pixel_size, pixel_size, wall.scale.z)
			set_pixel_color(pixel, 0)
			
			pixel.translate(
				Vector3(coordinate.x - offset.x, coordinate.y - offset.y, 0)
			)
			panel.add_child(pixel)
			row.append(pixel)
			pixel_values_row.append(0.0)
			
			coordinate.y += 1
			
		pixels.append(row)
		pixel_values.append(pixel_values_row)
	
	$HTTPRequest.request_completed.connect(_on_request_completed)
	
func linear_interpolation(last_coordinate: Vector2, current_coordinate: Vector2, step_size: float) -> Array:
	var output = []
	var vector_distance = current_coordinate - last_coordinate
	
	var distance = sqrt(vector_distance.x ** 2 + vector_distance.y ** 2) 
	var move_steps = distance / step_size
	var move_percentage = 1 / move_steps
	
	for i in range(ceili(move_steps)):
		output.append(
			vector_distance - vector_distance * move_percentage * i + last_coordinate
		)
	return output

var last_cursor_coordinate: Vector2 = Vector2(-1, -1)

func _on_collidable_panel_update_board(uv_coordinate):
	var current_cursor_coordinate = uv_coordinate * (resolution - 1)
	
	if last_cursor_coordinate < Vector2(0, 0):
		last_cursor_coordinate = current_cursor_coordinate
	
	const brush_radius = 2
		
	var cursor_coordinates = [current_cursor_coordinate]
	cursor_coordinates += linear_interpolation(last_cursor_coordinate, current_cursor_coordinate, brush_radius)
	
	for cursor_coordinate in cursor_coordinates:
		for y in range(resolution):
			for x in range(resolution):
				var distance_sqaured = (x - cursor_coordinate.x)**2 + (y - cursor_coordinate.y)**2
				if distance_sqaured < brush_radius * brush_radius:
					var pixel_coordinate = Vector2i(x, y)
					var intensity = brush_radius * brush_radius - distance_sqaured
					
					if pixel_values[resolution - pixel_coordinate.y - 1][resolution - pixel_coordinate.x - 1] > intensity:
						continue
					
					set_pixel_value(pixel_coordinate, intensity)
	
	last_cursor_coordinate = current_cursor_coordinate

func _on_static_body_3d_clear_board():
	clear_board()
	
var busy = false

func _on_static_body_3d_submit():
	if busy:
		return
	busy = true
	var json = JSON.stringify(pixel_values)
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request("http://127.0.0.1:5000/activations", headers, HTTPClient.METHOD_POST, json)

func _on_request_completed(_result, _response_code, _headers, body):
	busy = false
	print(body.size())
	neural_net.update_params(body)


func _on_collidable_panel_reset_cursor_coordinate():
	last_cursor_coordinate = Vector2(-1, -1)
