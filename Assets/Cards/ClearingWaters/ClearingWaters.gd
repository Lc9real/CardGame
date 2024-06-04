extends Node3D

var card: Node3D
var game_manager: Node


func activated():
	game_manager.spawnSelectHighlighters(true, self)
	
func getSelectedSquare(square: Vector2):
	if square == Vector2(-1,-1):
		card.discardCard()
		return
	var cardChoosen = game_manager.allSquares[square.x][square.y].card
	for effect in cardChoosen.effects:
		game_manager.removeEffect(card, effect)
	card.discardCard()
		
