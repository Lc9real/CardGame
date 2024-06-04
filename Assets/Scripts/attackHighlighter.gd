extends Node3D

var pos: Vector2
var game_manager: Node
var card: Node3D
var id: int


func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			game_manager.attackHighlighterClicked(pos, id, card, card.squareCoords)
