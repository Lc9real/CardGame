extends RichTextLabel

@onready var game_manager = %GameManager
@onready var player_1_health = $"../Player1Health"
@onready var player_2_health = $"../Player2Health"



func _process(_delta):
	var turn = game_manager.turn
	var textTemp = ""
	match turn:
		1:
			textTemp = "Player 1 Draw Phase"
		2:
			textTemp = "Player 1 Card Phase"
		3:
			if !game_manager.reactionTurn:
				textTemp = "Player 1 Motion Phase"
			else:
				textTemp = "Player 2 Reaktion Phase"
		4:
			textTemp = "Player 1 Discard Phase"
		5:
			textTemp = "Player 2 Draw Phase"
		6:
			textTemp = "Player 2 Card Phase"
		7:
			if !game_manager.reactionTurn:
				textTemp = "Player 2 Motion Phase"
			else:
				textTemp = "Player 1 Reaktion Phase"
		8:
			textTemp = "Player 2 Discard Phase"
	text = textTemp
	player_1_health.text = str(game_manager.playerHealth1)
	player_2_health.text = str(game_manager.playerHealth2)
