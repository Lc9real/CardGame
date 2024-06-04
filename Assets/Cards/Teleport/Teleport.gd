extends Node3D

var card: Node3D
var game_manager: Node
var selectedTedMonsterSquare: Vector2 = Vector2(-1,-1)


func activated():
	game_manager.spawnSelectHighlighters(true, self)
	
func getSelectedSquare(square: Vector2):
	if square == Vector2(-1,-1):
		card.discardCard()
		return
	
	if selectedTedMonsterSquare != Vector2(-1,-1):
		
		game_manager.moveCharacter(selectedTedMonsterSquare, square, true)
		
		card.discardCard()
	else:
		selectedTedMonsterSquare = square
		game_manager.spawnSelectHighlighters(false, self)
