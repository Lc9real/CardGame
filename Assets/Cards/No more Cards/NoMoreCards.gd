extends Node3D

var card: Node3D
var game_manager: Node

func activated():
	game_manager.cardPlaced.connect(cardPlaced)


func cardPlaced(placedCard: Node3D, _cardHolderID: int, _index: int):
	placedCard.discardCard()
	card.discardCard()
