extends CardMultiplayer

# Refrences
@onready var script_holder = $ScriptHolder

# If Card was Placed for a Reaktion
var reactionPlace: bool

func _ready():
	super()
	Placement = "magicCardPlacement"
	# If card is Passive add and Activate the script
	script_holder.set_script(data.magicScript)
	script_holder.game_manager = game_manager
	script_holder.card = self
	

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	super(_camera, event, _position, _normal, _shape_idx)
	# if its an Reaktion Turn Activate Card
	if event is InputEventMouseButton && !onGrave:
		# Start Dragging
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			# Enable dragging when a Reaction turn happens
			if ownerID == 1: isDragging = (game_manager.turn==7 && game_manager.reactionTurn) || isDragging
			elif ownerID == 2: isDragging = (game_manager.turn==3 && game_manager.reactionTurn) || isDragging
	# Enable Activation of Card when a Reaction turn happens
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed == true:
			if !hovering && cardHolderID != 0 && !isActivated:
				if game_manager.reactionTurn && game_manager.reactionPoints >= 1:
					if ((game_manager.turn == 7 && ownerID == 1) ||
						(game_manager.turn == 3 && ownerID == 2)):
							if !data.passive:
								activateCard()
						
							if data.instantEffect:
								reactionPlace = true
							else:
								if !data.selectBeforActivation:
									reactionPlace = true
									endReactionTurn()

func activateCard():
	# Activate Script Passive Cards cant get Activated
	if !data.passive && !game_manager.firstRound:
		script_holder.activated()
		super()
		game_manager.spellCardActivated.emit(self)
		

func discardCard():
	super()
	script_holder.set_script(null)
	# Remove Reaktion Points and End Turn
	if reactionPlace:
		endReactionTurn()
	if data.passive:
		game_manager.spellCardActivated.emit(self)
	
func _unhandled_input(event):
	super(event)
	if event is InputEventMouseButton && draggingEnd:
		if event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			if draggingState == 1:
				# Activate Passive Card when Placed Down
				if data.passive:
					script_holder.activated()
				# Reaktion turn
				if game_manager.reactionTurn == ownerID && game_manager.reactionPoints >= 1:
						if !data.passive:
							activateCard()
						
						if data.instantEffect:
							reactionPlace = true
						else:
							if !data.selectBeforActivation:
								reactionPlace = true
								endReactionTurn()
		draggingEnd = false

# Ends the Reaction turn 
func endReactionTurn():
	if reactionPlace:
		reactionPlace = false
		game_manager.reactionPoints -= 1
		game_manager.reactionTurnEnd()
