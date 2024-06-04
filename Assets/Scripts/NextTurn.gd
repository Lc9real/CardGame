extends Button


@onready var game_manager = %GameManager


func _on_button_down():
	game_manager.nextTurn()

