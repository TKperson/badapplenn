extends Node3D

const LABEL = preload("res://scenes/dnn/label.tscn")

var labels: Array
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(10):
		var label = LABEL.instantiate()
		label.set_text(str(i))
		label.position = Vector3(i * 2, 0, 0)
		labels.append(label)
		add_child(label)
