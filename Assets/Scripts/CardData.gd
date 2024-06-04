extends Resource
class_name CardData

@export var cardID: int
@export var cardName: String
@export var description: String
@export var image: Texture
@export var cardLevel: int

@export_group("Magic Card")
@export var MagicCard: bool
@export var instantEffect: bool
@export var selectBeforActivation: bool
@export var passive: bool

@export var magicScript: Script



@export_group("Creature")
@export var type: MyEnums.Types



@export var health: float

@export var firstAttackName: String
@export var firstAttackDescription: String
@export var firstAttackDamage: float
@export var firstAttackRange = [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]]
@export var firstAttackCost: int = 1


@export var secondAttackName: String
@export var secondAttackDescription: String
@export var secondAttackDamage: float
@export var secondAttackRange = [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]]
@export var secondAttackCost: int = 2


@export var thirdAttackName: String
@export var thirdAttackDescription: String
@export var thirdAttackDamage: float
@export var thirdAttackRange = [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]]
@export var thirdAttackCost: int = 3



@export var chracterNode: PackedScene

@export var attackScript: Script

@export var movement = [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]]



