extends uiCard

@onready var attack_1 = $HitBox/Attack1
@onready var attack_1_damage = $"HitBox/Attack1 Damage"
@onready var attack_1_description = $"HitBox/Attack1 Description"
@onready var attack_2 = $HitBox/Attack2
@onready var attack_2_damage = $"HitBox/Attack2 Damage"
@onready var attack_2_description = $"HitBox/Attack2 Description"
@onready var attack_3 = $HitBox/Attack3
@onready var attack_3_damage = $"HitBox/Attack3 Damage"
@onready var attack_3_description = $"HitBox/Attack3 Description"
@onready var _health = $HitBox/Health





func _ready():
	super()
	_health.text = str(data.health)
	
	attack_1.text = data.firstAttackName
	attack_1_description.text = data.firstAttackDescription
	if(data.firstAttackDamage > 0): attack_1_damage.text = str(data.firstAttackDamage)
	else: attack_1_damage.text = ""
	
	attack_2.text = data.secondAttackName
	attack_2_description.text = data.secondAttackDescription
	if(data.secondAttackDamage > 0): attack_2_damage.text = str(data.secondAttackDamage)
	else: attack_2_damage.text = ""
	
	attack_3.text = data.thirdAttackName
	attack_3_description.text = data.thirdAttackDescription
	if(data.thirdAttackDamage > 0): attack_3_damage.text = str(data.thirdAttackDamage)
	else: attack_3_damage.text = ""
