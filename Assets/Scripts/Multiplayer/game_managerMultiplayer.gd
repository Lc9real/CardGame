extends Node


# Refrences

var creatureCardRefrence: PackedScene = preload("res://Assets/Scenes/CreatureCard.tscn")
var magicCardRefrence: PackedScene = preload("res://Assets/Scenes/MagicCard.tscn")
const deckRefrence: PackedScene = preload("res://Assets/Scenes/deck.tscn")
const attackButtonsRefrence = preload("res://Assets/Scenes/attack_buttons.tscn")
const attackHighlighterRefrence = preload("res://Assets/Scenes/attackHighlighter.tscn")
const moveHighlighterRefrence = preload("res://Assets/Scenes/moveHighlighter.tscn")
const selectHighlighterRefrence = preload("res://Assets/Scenes/selectHighlighter.tscn")
const damageIndicator = preload("res://Assets/Scenes/damageIndicator.tscn")
@onready var won_screen = $"../Control/WonScreen"
@onready var camera_3d = $"../Camera3D"
@onready var graveObj1 = $"%Field/Cards/1PlayerCard/Grave"
@onready var graveObj2 = $"%Field/Cards/2PlayerCard/Grave"
@onready var deck1HolderRefrence = $"%Field/Cards/1PlayerCard/Deck"
@onready var deck2HolderRefrence = $"%Field/Cards/2PlayerCard/Deck"
var deck1Obj: Node3D
var deck2Obj: Node3D

# Data
var spawnByCardHolderID: Array[Array] = [[0,1], [2, 3], [3, 4], [5, 6], [6, 7], [8, 9]] 
var playerHealth1: float
var playerHealth2: float



#	Field
var allSquares: Array[Array]
var fieldSize = 12
var fieldScale = 24

#	Turn
var turn: int
var firstRound: bool = true
#		Reaktion
var reactionPoints: int
var reactionTurn: int # 1: Player 1 Reaction Turn; 2: Player 2 Reaction Turn
#		Fight
var maPoints: int
var damageAdvantage: Dictionary = {"NORMAL:NORMAL": 0}

#	Card
var cards: Array[CardData]

var deck1: Array
var deck2: Array
var playingDeck1: Array
var playingDeck2: Array

var hand1: Array[Node3D]
var hand2: Array[Node3D]

var creatureCardHolder1: Array[Array]
var creatureCardHolder2: Array[Array]

var grave1: Array[Node3D]
var grave2: Array[Node3D]

# Temp var
var cardD: Node3D # Defending Card
var idA: int # Attack ID 1: First Attack; 2: Second Attack; 3: Third Attack
var cardA: Node3D # Attacking Card

var attackButtons: Control
var moveHighlighters: Array[Node3D]
var attackHighlighters: Array[Node3D]
var selectHighlighters: Array[Node3D]

var choosenCharacterCard: Node3D
var choosenMagicCard: Node3D

var magicCardSelect: bool = false

# Signals
signal monster_damaged(damage: int, damagedCard: Node3D, damegingCard: Node3D)
signal monster_destroyed(destroyingCard: Node3D, destroyedCard: Node3D, pos: Vector2, health: float)
signal monster_summond(card: Node3D, pos: Vector2)
signal spellCardActivated(card: Node3D)
signal cardPlaced(card: Node3D, cardHolderID: int, index: int)
signal cardTaken(card: Node3D)
signal cardAddedToGrave(card: Node3D, player: int)


func _ready():
	# Get All Cards
	var dir = DirAccess.open("res://Assets/Cards/")
	for i in range(dir.get_directories().size()):
		cards.append(null)
	for folder in dir.get_directories():
		var dir2 = DirAccess.open("res://Assets/Cards/"+folder)
		for file in dir2.get_files():
			if file.ends_with(".tres"):
				var res: Resource = load("res://Assets/Cards/"+folder+"/"+file)
				if res.get_script() == load("res://Assets/Scripts/CardData.gd"):
					cards[res.cardID] = res
	
	
	
	
	if !multiplayer.is_server() || !multiplayer.multiplayer_peer: return
	deck1 = GlobalData.deck1
	deck2 = GlobalData.deck2
	
	# Fill Card Holders
	for i in range(12):
		creatureCardHolder1.append([])
		creatureCardHolder2.append([])
	# Shuffel Decks
	randomize()
	playingDeck1 = deck1
	playingDeck1.shuffle()
	randomize()
	playingDeck2 = deck2
	playingDeck2.shuffle()
	
	playerHealth1 = 400
	playerHealth2 = 400
	
	# Creating Deck Obj
	deck1Obj = deckRefrence.instantiate()
	deck1Obj.position = deck1HolderRefrence.global_position
	deck1Obj.position.y += 0.6
	deck1Obj.scale.y = playingDeck1.size()
	deck1Obj.player = 1
	deck1Obj.game_manager = self
	get_tree().current_scene.add_child.call_deferred(deck1Obj)
	
	deck2Obj = deckRefrence.instantiate()
	deck2Obj.position = deck2HolderRefrence.global_position
	deck2Obj.position.y+=0.6
	deck2Obj.scale.y = playingDeck2.size()
	deck2Obj.player = 2
	deck2Obj.game_manager = self
	get_tree().current_scene.add_child.call_deferred(deck2Obj)
	# Give Out the cards
	playerStartingCards()
	
	# Prepare Field
	var i = 0
	for x in range(fieldSize):
		allSquares.append([])
		for y in range(fieldSize):
			allSquares[x].append(SquareData.new(x, y, i, fieldScale, fieldSize))
			i += 1
	turn = 2
# Spawn the Chracter in by getting a free position and setting it
func spawnCharacter(player: int, cardID: int, card: Node3D, holderID: int) -> Vector2:
	
	var step: int = floor(fieldSize/6.0)
	# Go through Placement nearest to card
	for j in range(2):
		for i in range(step):
			var x: int
			if player == 1: x = j
			else: x = fieldSize-1-j
			if not allSquares[x][step*holderID-i].occupied:
				allSquares[x][step*holderID-i].occupied = true
				allSquares[x][step*holderID-i].cardID = cardID
				allSquares[x][step*holderID-i].ownerID = player
				allSquares[x][step*holderID-i].card = card
				allSquares[x][step*holderID-i].type = cards[cardID].type
				monster_summond.emit(card, Vector2(x, step*holderID-i))
				return Vector2(allSquares[x][step*holderID-i].x, allSquares[x][step*holderID-i].y)
	# If full go through all availables
	for j in range(2):
		for y in range(fieldSize):
			var x: int
			if player == 1: x = j
			else: x = fieldSize-1-j
			if not allSquares[x][y].occupied:
				allSquares[x][y].occupied = true
				allSquares[x][y].cardID = cardID
				allSquares[x][y].ownerID = player
				allSquares[x][y].card = card
				allSquares[x][y].type = cards[cardID].type
				monster_summond.emit(card, Vector2(x, y))
				return Vector2(allSquares[x][y].x, allSquares[x][y].y)
	# If still non found return error
	return Vector2(-1,-1)
# Take one Card from the deck
func takeCard(player:int, start: bool = false):
	if ((player == 1 && turn == 1 && hand1.size()<5) || 
		(player==2 && turn == 5 && hand2.size()<5)):
		
		var cardData
		
		if player == 1: 
			cardData = cards[playingDeck1[0]]
			playingDeck1.remove_at(0)
			if playingDeck1.size()<=0:
				deck1Obj.queue_free()
			else:
				deck1Obj.scale.y = playingDeck1.size()
		else: 
			cardData = cards[playingDeck2[0]]
			playingDeck2.remove_at(0)
			if playingDeck2.size()<=0:
				deck2Obj.queue_free()
			else:
				deck2Obj.scale.y = playingDeck2.size()
			
		
		var cardObj: Node3D
		
		# Spawning Magic or Creature Card
		if !cardData.MagicCard: cardObj = creatureCardRefrence.instantiate()
		else: cardObj = magicCardRefrence.instantiate()
		get_tree().current_scene.add_child.call_deferred(cardObj)
		# Set all Variables on the Card
		cardObj.ownerID = player
		cardObj.game_manager = self
		cardObj.data = cardData
		cardObj.cardID = cardData.cardID
		cardObj.isDragging = true
		# Setting Parent and Position 
		if player == 1: cardObj.global_position = deck1Obj.global_position
		else: cardObj.global_position = deck2Obj.global_position
		
		cardTaken.emit(cardObj)
		if !start:
			nextTurn()
		else:
			
			return cardObj

#get to the next turn
func nextTurn():
	# When Reaktion turn stop from adding turn
	if reactionTurn != 0:
		reactionTurnEnd()
		if maPoints <= 0:
			nextTurn()
		return
	
	turn+=1
	if turn>8:
		turn = 1
		
	# when first round just card Placement
	if firstRound:
		if turn == 3:
			turn = 5
		elif turn == 7:
			turn = 1
			firstRound = false
	
	# Delet all highlighters and attack Buttons
	clearHighlighters()

	# Fight turn set Points
	if turn == 3 || turn == 7:
		maPoints = 3
		reactionPoints = 1
	
	# Set Camera and handle Effects
	if turn == 1:
		camera_3d.position = Vector3(-25, 20, 0)
		camera_3d.rotation_degrees = Vector3(-52.5, -90, 0)
		handleEffects(2)
	elif turn == 5:
		camera_3d.position = Vector3(25, 20, 0)
		camera_3d.rotation_degrees = Vector3(-52.5, 90, 0)
		handleEffects(1)
	# when hand is full skip draw turn
	if turn == 1 && hand1.size()>=5:
		nextTurn()
	elif turn == 5 && hand2.size()>=5:
		nextTurn()
	
# Start an Attack
func caracterAttack(square: Vector2, card: Node3D, MousePos: Vector2):
	
	if reactionTurn:
		return
	# Skip if not your FIght Turn
	if not ((turn == 3 && allSquares[square.x][square.y].ownerID == 1)
	 || 	(turn == 7 && allSquares[square.x][square.y].ownerID == 2)):
		return
	# Skip if you are activating a Magic Card
	if magicCardSelect:
		return
	
	clearHighlighters()
	
	# Setting up attack button var
	attackButtons = attackButtonsRefrence.instantiate()
	get_tree().current_scene.add_child.call_deferred(attackButtons)
	attackButtons.game_manager = self
	attackButtons.square = square
	attackButtons.position = MousePos
	
	# Setting up attack Button visibility and text
	if card.data.firstAttackCost != 0:
		attackButtons.get_child(0).visible = true
		attackButtons.get_child(0).text = card.data.firstAttackName
		if card.data.firstAttackCost <= maPoints:
			attackButtons.get_child(0).disabled = false
	if card.data.secondAttackCost != 0:
		attackButtons.get_child(1).visible = true
		attackButtons.get_child(1).text = card.data.secondAttackName
		if card.data.secondAttackCost <= maPoints:
			attackButtons.get_child(1).disabled = false
	if card.data.thirdAttackCost != 0:
		attackButtons.get_child(2).visible = true
		attackButtons.get_child(2).text = card.data.thirdAttackName
		if card.data.thirdAttackCost <= maPoints:
			attackButtons.get_child(2).disabled = false


# Spawns the Highlighters
func spawnAttackHighlighter(id: int, square: Vector2):
	
	clearHighlighters()
	var attackedPlayer: int
	if  allSquares[square.x][square.y].ownerID == 1: attackedPlayer = 2
	else: attackedPlayer = 1
	# Give the ability to Attack the player if character is on the Edge and all enemy chracter are dead
	if !hasCharacteronField(attackedPlayer):
		if ((allSquares[square.x][square.y].card.ownerID == 1 && square.x >= fieldSize-1) || 
			(allSquares[square.x][square.y].card.ownerID == 2 && square.x == 0)):
			var highlighter = attackHighlighterRefrence.instantiate()
			highlighter.pos = Vector2(-2, -2)
			highlighter.game_manager = self
			highlighter.card = allSquares[square.x][square.y].card
			highlighter.id = id
			
			highlighter.scale = Vector3(5, 1, 50)
			if allSquares[square.x][square.y].card.ownerID == 1: highlighter.position = Vector3(12, 0, 0)
			else: highlighter.position = Vector3(-12, 0, 0)
			get_tree().current_scene.add_child.call_deferred(highlighter)
			attackHighlighters.append(highlighter)
		
	# Getting Attack Range depending on the Attack
	var cardAttackRange: Array
	if id == 1: cardAttackRange = cards[allSquares[square.x][square.y].cardID].firstAttackRange
	elif id == 2: cardAttackRange = cards[allSquares[square.x][square.y].cardID].secondAttackRange
	elif id == 3: cardAttackRange = cards[allSquares[square.x][square.y].cardID].thirdAttackRange
	# Reversing range for other Player
	if allSquares[square.x][square.y].ownerID == 2:
		cardAttackRange.reverse()
	
	# Going through range and Placing markers where you can attack
	for x in range(cardAttackRange.size()):
		for y in range(cardAttackRange.size()):
			if cardAttackRange[x][y] == 1:
				# Determening Field Pos of range
				var x_pos: int = (cardAttackRange.size()-1)/2-x+square.x
				var y_pos: int = y-(cardAttackRange.size()-1)/2+square.y
				# If its in the field
				if x_pos<allSquares.size() && y_pos>=0 && y_pos<allSquares.size() && x_pos>=0:
					# if Character is on the field
					if allSquares[x_pos][y_pos].occupied:
						# Spawn the Highligter and set its var
						var highlighter = attackHighlighterRefrence.instantiate()
						highlighter.pos = Vector2(x_pos, y_pos)
						highlighter.game_manager = self
						highlighter.card = allSquares[square.x][square.y].card
						highlighter.id = id
						
						highlighter.position = Vector3(allSquares[x_pos][y_pos].x_pos, 0, allSquares[x_pos][y_pos].y_pos)
						get_tree().current_scene.add_child.call_deferred(highlighter)
						
						attackHighlighters.append(highlighter)

func spawnMoveHighlighters(square: Vector2, card: Node3D):
	# Stop if a magicCard gets activated
	if magicCardSelect:
		return
	# Stop if not player Fight turn
	if not ((turn == 3 && allSquares[square.x][square.y].ownerID == 1) || (turn == 7 && allSquares[square.x][square.y].ownerID == 2)):
			return
	# Stop if card is frozen
	if allSquares[square.x][square.y].card.effects.has(MyEnums.Effects.FREEZE) || reactionTurn:
		return
		
	
	
	clearHighlighters()
	
	# Save Card that inintiated Movement
	choosenCharacterCard = card
	
	# Get Movement Range
	var cardMovement: Array = card.data.movement
	# Reverse Range for Opposit Player
	if card.ownerID == 2:
		cardMovement.reverse()
	# Going through range and Placing markers where you can Move
	for x in range(cardMovement.size()):
		for y in range(cardMovement.size()):
			if cardMovement[x][y] == 1:
				# Determening Field Pos of range
				var x_pos = (cardMovement.size()-1)/2-x+square.x
				var y_pos = y-(cardMovement.size()-1)/2+square.y
				# if Square is Empty
				if x_pos<allSquares.size() && y_pos>=0 && y_pos<allSquares.size() && x_pos>=0 && not allSquares[x_pos][y_pos].occupied:
					# Spawn the Highligter and set its var
					var highlighter = moveHighlighterRefrence.instantiate()
					highlighter.pos = Vector2(x_pos, y_pos)
					highlighter.game_manager = self
					highlighter.position = Vector3(allSquares[x_pos][y_pos].x_pos, 0, allSquares[x_pos][y_pos].y_pos)
					get_tree().current_scene.add_child.call_deferred(highlighter)
					
					moveHighlighters.append(highlighter)

func spawnSelectHighlighters(monsters: bool, magicCard: Node3D):
	clearHighlighters()
	
	# Make Clear MagicCard is Selecting target
	magicCardSelect = true
	# Saving Card
	choosenMagicCard = magicCard
	# Go through the whole field and Place highlighters on monster or emptys
	for x in range(fieldSize):
		# Stop Players from using Spells spawning in enemy spawn
		if ((magicCard.card.ownerID == 1 && x >= fieldSize-2) || 
			(magicCard.card.ownerID == 2 && x <= 1)):
			continue
		for y in range(fieldSize):
			
			if allSquares[x][y].occupied==monsters:
				# Spawn the Highligter and set its var
				var highlighter = selectHighlighterRefrence.instantiate()
				highlighter.pos = Vector2(x, y)
				highlighter.game_manager = self
				highlighter.position = Vector3(allSquares[x][y].x_pos, 0, allSquares[y][y].y_pos)
				get_tree().current_scene.add_child.call_deferred(highlighter)
				
				selectHighlighters.append(highlighter)
	# If no selections Return error
	if selectHighlighters.size() == 0:
		selectHighlighterClicked(Vector2(-1,-1))


# Handels Click on the Highlighter
func attackHighlighterClicked(pos: Vector2, id: int, card: Node3D, _cardPos: Vector2):
	clearHighlighters()
	
	if pos == Vector2(-2, -2):
		var damage: float
		if id == 1: damage = card.data.firstAttackDamage
		elif id == 2: damage = card.data.secondAttackDamage
		elif id == 3: damage = card.data.thirdAttackDamage
		if damage > 0:
			# Carrys out the Attack
			if id == 1:
				card.data.attackScript.firstAttack(pos, card.squareCoords, card, self)
				maPoints-=card.data.firstAttackCost
			elif id == 2:
				card.data.attackScript.secondAttack(pos, card.squareCoords, card, self)
				maPoints-=card.data.secondAttackCost
			elif id == 3:
				card.data.attackScript.thirdAttack(pos, card.squareCoords, card, self)
				maPoints-=card.data.thirdAttackCost
			if maPoints <= 0:
				nextTurn()
		return
	
	# stores variables for after the attack
	cardD = allSquares[pos.x][pos.y].card # Defending Card
	idA = id # Attack ID 1: First Attack; 2: Second Attack; 3: Third Attack
	cardA = card # Attacking Card
	# Starts Reaktion turn
	reactionTurnStart()

func moveHighlighterClicked(pos: Vector2):
	clearHighlighters()
	
	# Move the Character
	moveCharacter(choosenCharacterCard.squareCoords, pos)
	
	# Remove maPoint
	maPoints -= 1
	if maPoints <= 0:
		nextTurn()

func selectHighlighterClicked(pos: Vector2):
	
	clearHighlighters(false)
	
	# Send Selections to Card
	choosenMagicCard.getSelectedSquare(pos)
	magicCardSelect = false
	

# Start a Reaction Turn
func reactionTurnStart():
	# Sets Camera
	if turn == 7:
		camera_3d.position = Vector3(-25, 20, 0)
		camera_3d.rotation_degrees = Vector3(-52.5, -90, 0)
		reactionTurn=1
	elif turn==3:
		camera_3d.position = Vector3(25, 20, 0)
		camera_3d.rotation_degrees = Vector3(-52.5, 90, 0)
		reactionTurn=2
	# Indicates reaktion turn
	
	# Stops turn if player has no more points
	if reactionPoints == 0 || cardA.ownerID == cardD.ownerID:
		reactionTurnEnd()
# Ends the Reaction turn
func reactionTurnEnd():
	# Sets Camera
	if turn == 3:
		camera_3d.position = Vector3(-25, 20, 0)
		camera_3d.rotation_degrees = Vector3(-52.5, -90, 0)
	elif turn==7:
		camera_3d.position = Vector3(25, 20, 0)
		camera_3d.rotation_degrees = Vector3(-52.5, 90, 0)
	# Indicates no Reaktion turn
	reactionTurn = 0
	
	# Carrys out the Attack
	if idA == 1:
		cardA.data.attackScript.firstAttack(cardD.squareCoords, cardA.squareCoords, cardA, self)
		maPoints-=cardA.data.firstAttackCost
	elif idA == 2:
		cardA.data.attackScript.secondAttack(cardD.squareCoords, cardA.squareCoords, cardA, self)
		maPoints-=cardA.data.secondAttackCost
	elif idA == 3:
		cardA.data.attackScript.thirdAttack(cardD.squareCoords, cardA.squareCoords, cardA, self)
		maPoints-=cardA.data.thirdAttackCost
	if maPoints <= 0:
		nextTurn()
	
# moves The Character
func moveCharacter(from: Vector2, to: Vector2, instant: bool = false):
	var choosenCard = allSquares[from.x][from.y].card
	# Sets var for new Point
	allSquares[to.x][to.y].cardID = allSquares[from.x][from.y].cardID
	allSquares[to.x][to.y].ownerID = allSquares[from.x][from.y].ownerID
	allSquares[to.x][to.y].card = allSquares[from.x][from.y].card
	allSquares[to.x][to.y].type = allSquares[from.x][from.y].type
	allSquares[to.x][to.y].occupied = true
	
	# Remove info from the old Point
	allSquares[from.x][from.y].cardID = 0
	allSquares[from.x][from.y].ownerID = 0
	allSquares[from.x][from.y].occupied = false
	allSquares[from.x][from.y].card = null
	allSquares[from.x][from.y].type = ""
	
	# Move the Character Model
	choosenCard.moveCharacter(to, instant)
# Returns a Vector3 from the Field pos
func getRealPosFromSquarePos(pos: Vector2) -> Vector3:
	return Vector3(allSquares[pos.x][pos.y].x_pos, 0, allSquares[pos.x][pos.y].y_pos)

# Adds a card to the Hand
func addCardToHand(player: int, card: Node3D) -> int:
	if player == 1:
		hand1.append(card)
		return hand1.size()-1
	elif player == 2:
		hand2.append(card)
		return hand2.size()-1
	else:
		return 0
# Removes a Card from the Hand
func removeCardFromHand(player: int, card: Node3D):
	if player == 1:
		hand1.remove_at(hand1.find(card))
		for i in range(hand1.size()):
			hand1[i].index = i+1
	elif player == 2:
		hand2.remove_at(hand2.find(card))
		for i in range(hand2.size()):
			hand2[i].index = i+1

# Adds Card to Card Placement
func addToCardPlacement(player: int, cardHolder: int, card: Node3D):
	
	if player == 1:
		creatureCardHolder1[cardHolder].append(card)
		cardPlaced.emit(card, cardHolder, creatureCardHolder1[cardHolder].size()-1)
		return creatureCardHolder1[cardHolder].size()-1
	elif player == 2:
		cardPlaced.emit(card, cardHolder, creatureCardHolder2[cardHolder].size()-1)
		creatureCardHolder2[cardHolder].append(card)
		return creatureCardHolder2[cardHolder].size()-1
	else:
		return -1
# Moves Card to Card Placement
func moveToCardPlacement(player: int, cardHolder: int, index: int, newCardHolder: int):
	if player == 1:
		creatureCardHolder1[newCardHolder].append(creatureCardHolder1[cardHolder][index])
		creatureCardHolder1[cardHolder].remove_at(index)
		return creatureCardHolder1[newCardHolder].size()-1
	elif player == 2:
		creatureCardHolder2[newCardHolder].append(creatureCardHolder2[cardHolder][index])
		creatureCardHolder2[cardHolder].remove_at(index)
		return creatureCardHolder2[newCardHolder].size()-1
	else:
		return -1
# Removes Card from Card Placement and sends to Grave
func removeFromCardPlacement(player: int, cardHolder: int, index: int):
	if player == 1:
		creatureCardHolder1[cardHolder].remove_at(index)
	elif player == 2:
		creatureCardHolder2[cardHolder].remove_at(index)

# Adds Card to the Grave
func addToGrave(card: Node3D):
	var y
	if card.ownerID == 2:
		y = 180
	else:
		y = 0
	card.rotation_degrees = Vector3(0,y, 0)
	cardAddedToGrave.emit(card, card.ownerID)
	if card.ownerID == 1: 
		grave1.append(card)
		card.objectsToMove[card] = MoveClass.new(Vector3(graveObj1.global_position.x, graveObj1.global_position.y + 0.6 + 0.06*grave1.size(), graveObj1.global_position.z), 25)
	else: 
		grave2.append(card)
		card.objectsToMove[card] = MoveClass.new(Vector3(graveObj2.global_position.x, graveObj2.global_position.y + 0.6 + 0.06*grave2.size(), graveObj2.global_position.z), 25)

# Adds an Effect to a Card
func addEffectToCard(square: Vector2, effect: MyEnums.Effects , duration: int, strength: int):
	allSquares[square.x][square.y].card.effects[effect] = MyEnums.new(duration, strength)
# Damages or Heals Card
func damageCard(square: Vector2, damage: float, attackerType: MyEnums.Types, attackerCard: Node3D):
	if square == Vector2(-2,-2):
		var defender: int
		if attackerCard.ownerID == 1: defender = 2
		elif attackerCard.ownerID == 2: defender = 1
		damagePlayer(defender, damage)
		return
	
	# Gets Type
	var defenderType = allSquares[square.x][square.y].type
	var damageReduction: float
	var schield = false
	
	# Applie Weakness Effect if there
	if allSquares[square.x][square.y].card.effects.has(MyEnums.Effects.WEAKNESS):
		damage = damage*allSquares[square.x][square.y].card.effects[MyEnums.Effects.WEAKNESS].strenth

	# Gets Advanteges/Disadvanteges based on Type Pair through dictionary called damageAdvantage
	if damage > 0 && damageAdvantage.has(MyEnums.Types.keys()[attackerType] + ":" + MyEnums.Types.keys()[defenderType]):
		damageReduction=damage*damageAdvantage[MyEnums.Types.keys()[attackerType] + ":" + MyEnums.Types.keys()[defenderType]]/100
	damage = damage+damageReduction
	
	# Spawn visual
	var indicator = damageIndicator.instantiate()
	get_tree().current_scene.add_child.call_deferred(indicator)
	indicator.global_position = getRealPosFromSquarePos(square)
	if damage > 0:
		indicator.get_child(0).text = str(-damage)
	else:
		indicator.get_child(0).text = "+"+str(-damage)
		indicator.get_child(0).modulate = Color.GREEN
		indicator.global_position.y += 1
	
	
	
	
	# Destroy Schield if there
	if allSquares[square.x][square.y].card.effects.has(MyEnums.Effects.SCHIELD) && damage>0:
		allSquares[square.x][square.y].card.effects[MyEnums.Effects.SCHIELD].strength -= damage
		schield = true
		
		# If the Schield is destroyed Apply the remaining Damages
		if allSquares[square.x][square.y].card.effects[MyEnums.Effects.SCHIELD].strength <= 0:
			schield = false
			damage = allSquares[square.x][square.y].card.effects[MyEnums.Effects.SCHIELD].strength * -1
			allSquares[square.x][square.y].card.effects.erase(MyEnums.Effects.SCHIELD)
	# if there is nor schield or schield ran out Applies the remaining Damages
	if !schield:	
		# Applies the Damages
		allSquares[square.x][square.y].card.damageCard(damage)
		# Destroys Card if health ran out
		if allSquares[square.x][square.y].card.health<=0:
			monster_destroyed.emit(attackerCard, allSquares[square.x][square.y].card, square, allSquares[square.x][square.y].card.health)
			allSquares[square.x][square.y].card.discardCard()
		# Sends signal that an Monster was Damaged
		monster_damaged.emit(damage, allSquares[square.x][square.y].card, attackerCard)

func damagePlayer(player: int, damage: float):
	if player == 1: playerHealth1-=damage
	elif player == 2: playerHealth2-=damage
	if playerHealth1<=0:
		won_screen.text = "Player 2 Won the Game"
		await get_tree().create_timer(5.0).timeout
		get_tree().reload_current_scene()
	elif playerHealth2<=0:
		won_screen.text = "Player 1 Won the Game"
		await get_tree().create_timer(5.0).timeout
		get_tree().reload_current_scene()
# Handels the Effect Durations
func handleEffects(id: int):
	# Goes through all Squares
	for x in range(fieldSize):
			for y in range(fieldSize):
				if allSquares[x][y].occupied && allSquares[x][y].ownerID == id:
					# Goes through all Effects and decreases the duration and Applies them if needed
					for key in allSquares[x][y].card.effects:
						if key == MyEnums.Effects.POISON:
							damageCard(Vector2(x, y), allSquares[x][y].card.effects[key].strength, MyEnums.Types.POISON, null)
						
						allSquares[x][y].card.effects[key].duration -= 1
						# if effect ranout remove it
						if(allSquares[x][y].card.effects[key].duration == 0):
							removeEffect(allSquares[x][y].card, key)
# Removes Effects
func removeEffect(card: Node3D, effect: MyEnums.Effects):
	card.effects.erase(effect)
# Gives out the starting Cards for the Player
func playerStartingCards():
	var z = -6
	turn = 1
	for i in range(5):
		var cardObj = takeCard(1, true)
		cardObj.handID = addCardToHand(1, cardObj)+1
		cardObj.objectsToMove[cardObj] = MoveClass.new(Vector3(-24, 9.1, z), 100)
		cardObj.rotation_degrees.x = 180
		cardObj.isDragging = false
		z+=3.25
	turn = 5
	z=-6
	for i in range(5):
		var cardObj = takeCard(2, true)
		cardObj.handID = addCardToHand(2, cardObj)+1
		cardObj.objectsToMove[cardObj] = MoveClass.new(Vector3(24, 9.1, z), 100)
		cardObj.rotation_degrees.x = 180
		cardObj.isDragging = false
		z+=3.25
# Clears all Highlighters and Button
func clearHighlighters(magicCard:bool = true):
	for highlighter in moveHighlighters:
		highlighter.queue_free()
	moveHighlighters.clear()
	
	for highlighter in attackHighlighters:
		highlighter.queue_free()
	attackHighlighters.clear()
	
	if magicCard:
		if selectHighlighters.size() > 0:
			choosenMagicCard.card.discardCard()
	for highlighter in selectHighlighters:
		highlighter.queue_free()
	selectHighlighters.clear()
	
	if attackButtons:
		attackButtons.queue_free()
		attackButtons = null

func clearSquare(square: Vector2):
	allSquares[square.x][square.y] = SquareData.new(square.x, square.y, allSquares[square.x][square.y].id, fieldScale, fieldSize)

func hasCharacteronField(player: int) -> bool:
	var character = false
	for x in range(fieldSize):
		for y in range(fieldSize):
			if allSquares[x][y].occupied && allSquares[x][y].ownerID==player:
				character=true
	return character
