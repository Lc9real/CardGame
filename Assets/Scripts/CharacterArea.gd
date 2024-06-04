extends Node3D


var card: Node3D



func _on_area_3d_input_event(camera, event, _position, normal, shape_idx):
	if event is InputEventMouseButton:
		card.clickedOnCharacter(camera, event, _position, normal, shape_idx)
