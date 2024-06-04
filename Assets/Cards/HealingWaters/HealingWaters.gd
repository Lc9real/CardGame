extends Node3D
var card: Node3D
var game_manager: Node


func activated():
	game_manager.spawnSelectHighlighters(true, self)
	
func getSelectedSquare(square: Vector2):
	if square == Vector2(-1,-1):
		card.discardCard()
		return
	game_manager.damageCard(square, -100, MyEnums.Types.LIGHT, card)
	card.discardCard()
