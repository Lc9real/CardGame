static func firstAttack(attackedSquare: Vector2, _playerSquare: Vector2, card:Node3D, game_manager: Node):
	game_manager.damageCard(attackedSquare, card.data.firstAttackDamage, card.data.type, card)
	
static func secondAttack(attackedSquare: Vector2, playerSquare: Vector2, card:Node3D, game_manager: Node):
	game_manager.damageCard(attackedSquare, card.data.secondAttackDamage, card.data.type, card)
	game_manager.damageCard(playerSquare, 50, card.data.type, card)
	
static func thirdAttack(_attackedSquare: Vector2, _playerSquare: Vector2, _card:Node3D, _game_manager: Node):
	pass
