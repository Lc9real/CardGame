extends Control

var game_manager: Node
var square: Vector2

func _on_attack_1_button_down():
	game_manager.spawnAttackHighlighter(1, square)


func _on_attack_2_button_down():
	game_manager.spawnAttackHighlighter(2, square)


func _on_attack_3_button_down():
	game_manager.spawnAttackHighlighter(3, square)
