extends Node3D

func _ready():
	$SubViewport.size = $SubViewport/Label.size

func set_text(string: String):
	$SubViewport/Label.text = string

func set_material(material):
	$box.material_override = material
