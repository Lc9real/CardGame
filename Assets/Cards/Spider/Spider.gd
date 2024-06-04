


static func firstAttack(attackedSquare: Vector2, _playerSquare: Vector2, card:Node3D, game_manager: Node):
	game_manager.damageCard(attackedSquare, card.data.firstAttackDamage, card.data.type, card)
	if attackedSquare != Vector2(-2,-2):
		game_manager.addEffectToCard(attackedSquare, MyEnums.Effects.POISON, 5, 10)
	
static func secondAttack(attackedSquare: Vector2, _playerSquare: Vector2, _card:Node3D, game_manager: Node):
	game_manager.addEffectToCard(attackedSquare, MyEnums.Effects.FREEZE, 2, 1)
	
static func thirdAttack(_attackedSquare: Vector2, _playerSquare: Vector2, _card:Node3D, _game_manager: Node):
	pass
