extends Card

# Refrences
@onready var _health = $Rotation/Health
@onready var attack_1 = $Rotation/Attack1
@onready var attack_1_damage = $"Rotation/Attack1 Damage"
@onready var attack_1_description = $"Rotation/Attack1 Description"
@onready var attack_2 = $Rotation/Attack2
@onready var attack_2_damage = $"Rotation/Attack2 Damage"
@onready var attack_2_description = $"Rotation/Attack2 Description"
@onready var attack_3 = $Rotation/Attack3
@onready var attack_3_damage = $"Rotation/Attack3 Damage"
@onready var attack_3_description = $"Rotation/Attack3 Description"

# Area Refrences
const AREA = preload("res://Assets/Scenes/area.tscn")
var area: Node3D



# Data
var squareCoords: Vector2
var health: float
var effects: Dictionary
var character: Node3D

func _ready():
	super()
	
	# Setting Visuals
	health = data.health
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

	
	Placement = "creatureCardPlacement"
	
func activateCard():
	super()
	squareCoords = game_manager.spawnCharacter(ownerID, data.cardID, self, cardHolderID-1)
	
	# Create Character
	character = data.chracterNode.instantiate()
	get_tree().current_scene.add_child.call_deferred(character)
	character.global_position = game_manager.getRealPosFromSquarePos(squareCoords)
	print(squareCoords)
	print(game_manager.getRealPosFromSquarePos(squareCoords))
	
	if ownerID == 2: character.rotation_degrees.y = 180
	
	# Create Area
	area = AREA.instantiate()
	area.position = Vector3(0, 0, 0)
	area.card = self
	character.add_child(area)
	
func moveCharacter(pos: Vector2, instant: bool=false):
	squareCoords = pos
	if instant: character.position = game_manager.getRealPosFromSquarePos(squareCoords)
	else: objectsToMove[character] = MoveClass.new(game_manager.getRealPosFromSquarePos(squareCoords), 25)

func clickedOnCharacter(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			game_manager.spawnMoveHighlighters(squareCoords, self)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed == true:
			game_manager.caracterAttack(squareCoords, self, event.position)

func discardCard():
	super()
	if character:
		character.queue_free()
		effects.clear()
		game_manager.clearSquare(squareCoords)
		character = null

func damageCard(damage: float):
	health -= damage
	if health>data.health:
		health=data.health
	_health.text = str(health)
