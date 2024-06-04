extends Node3D
class_name Card

# Refrences
@onready var hovering_timer = $HoveringTimer
@onready var collision_shape_3d = $Rotation/Area3D/CollisionShape3D
@onready var _image = $Rotation/Image
@onready var _name = $Rotation/Name
@onready var _description = $Rotation/Description
@onready var _cardLevel = $Rotation/CardLevel

var cam: Camera3D
@export var game_manager: Node
var tree: Node3D
var Placement: String

# Data
var isActivated: bool;
var data: CardData
@export var cardID: int
var ownerID: int
var handID: int = 0
var cardHolderID: int
var hovering: bool = false
var onGrave: bool = false
var removedFromHand: bool = false
var isDragging: bool

var objectsToMove: Dictionary


# Temp
var draggingState: int # 0: Hand; 1: Card Placement; 2: Grave; 3: table
var lastCardHolderID: int

var LastValidPos: Vector3

var beforHoveringPos: Vector3
var beforHoveringRot: Vector3

var index:int

var draggingEnd: bool = false

func _ready():
	if !data:
		data = game_manager.cards[cardID]
	rotation_order = EULER_ORDER_YXZ
	
	if ownerID == 2: rotation_degrees.y = 180
		
	cam = get_viewport().get_camera_3d()
	isActivated = false
	
	var bigSize: float
	if data.image.get_width() > data.image.get_height(): bigSize = data.image.get_width()
	else: bigSize = data.image.get_height()
	
	_name.text = data.cardName
	_cardLevel.text = str(data.cardLevel)
	_image.texture = data.image
	_description.text = data.description
	_image.pixel_size = 2.25/bigSize
	
func _unhandled_input(event):
	if event is InputEventMouseButton && isDragging:
		if event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			isDragging = false
			draggingEnd = true
			
			if draggingState != 0:
				self.global_position.y -= 1
			if draggingState == 2:
				discardCard()
				return
			
			
			
			# Either on Hand or on CardHolder
			# Moved from Hand to CardHolder
			if ((handID != 0 && draggingState == 1 && cardHolderID != 0) ||
			   (!removedFromHand && handID == 0 && cardHolderID != 0)):
				game_manager.removeCardFromHand(ownerID, self)
				removedFromHand = true
				handID = 0
				index = game_manager.addToCardPlacement(ownerID, cardHolderID-1, self)
				lastCardHolderID = cardHolderID
				game_manager.cardPlaced.emit(self, cardHolderID, index)
			# Added to Hand
			elif !removedFromHand && handID == 0:
				handID = game_manager.addCardToHand(ownerID, self)+1
			# Moved Card Holder
			if cardHolderID != 0:
				if lastCardHolderID != cardHolderID:
					index = game_manager.moveToCardPlacement(ownerID, lastCardHolderID-1, index, cardHolderID-1)
				LastValidPos = global_position
				lastCardHolderID = cardHolderID
			# No Holder so gets Reseted to last position
			elif cardHolderID == 0 && removedFromHand:
				self.global_position = LastValidPos
				cardHolderID = lastCardHolderID
			
			var y
			if ownerID == 2:
				y = 180
			else:
				y = 0
			var x
			if (removedFromHand || draggingState==3) and !isActivated:
				x = 0
			else:
				x = 180
			
			rotation_degrees = Vector3(x,y, 0)
			
			
func _process(delta):
	smoothMovement(delta)
	handleDragging()

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton && !onGrave:
		# Start Dragging
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
			if ownerID == 1:
				isDragging = (game_manager.turn==2 || game_manager.turn==4)
			elif ownerID == 2:
				isDragging = (game_manager.turn==6 || game_manager.turn==8)
		
		# Activate Card
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed == true:
			if !hovering && cardHolderID != 0 && !isActivated:
				if (ownerID == 1 && game_manager.turn == 2) || (ownerID == 2 && game_manager.turn == 6):
					if !data.passive:
						activateCard()
	
func activateCard():
	objectsToMove[self] = MoveClass.new(Vector3(180, rotation_degrees.y, rotation_degrees.z), 1000, true)
	isActivated = true
	
func discardCard():
	# Clear Variables in other Scripts
	if removedFromHand:
		game_manager.removeFromCardPlacement(ownerID, lastCardHolderID-1, index)
	else:
		game_manager.removeCardFromHand(ownerID, self)
	
	# Disable Collision and Rotate Card Face Down
	collision_shape_3d.disabled = true
	rotation_degrees.x = 0
	
	# Deactivate Card
	if isActivated:
		isActivated = false
	onGrave = true
	# Adding to Grave
	game_manager.addToGrave(self)
	
	

# Hovering over Card Zoom into the Card Start
func _on_area_3d_mouse_entered():
	hovering_timer.start()
# Hovering Activated
func _on_hovering_timer_timeout():
	hovering_timer.stop()
	if !isDragging:
		# Set temp var
		beforHoveringPos = global_position
		beforHoveringRot = rotation_degrees
		tree = get_parent()
		
		# Set Parent
		get_parent().remove_child(self)
		cam.add_child(self)
		
		# Set Position and Rotation
		position = Vector3(0,0,-4)
		if isActivated || handID != 0:
			rotation_degrees = Vector3(0, -90 ,90)
		else:
			rotation_degrees = Vector3(0, 90 ,90)
		
		hovering = true
# Stop Hovering
func _on_area_3d_mouse_exited():
	hovering_timer.stop()
	if hovering:
		# Set Parents
		get_parent().remove_child(self)
		tree.add_child(self)
		
		# Set Poition and Rotation
		global_position = beforHoveringPos
		rotation_degrees = beforHoveringRot
		
		hovering = false

func smoothMovement(delta):
	for object in objectsToMove:
		if objectsToMove[object].rot:
			object.rotation_degrees = object.rotation_degrees.move_toward(objectsToMove[object].pos, delta*objectsToMove[object].speed)
			if object.rotation_degrees == objectsToMove[object].pos:
				objectsToMove.erase(object)
		else:
			object.global_position = object.global_position.move_toward(objectsToMove[object].pos, delta*objectsToMove[object].speed)
			if object.global_position == objectsToMove[object].pos:
				objectsToMove.erase(object)

func handleDragging():
	if isDragging && !onGrave:
		var space_state = get_world_3d().direct_space_state
		var mousepos = get_viewport().get_mouse_position()
		var origin = cam.project_ray_origin(mousepos)
		var end = origin + cam.project_ray_normal(mousepos) * 80
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		
		query.collide_with_areas = true
		query.exclude = [$Rotation/Area3D/CollisionShape3D, $Rotation/Area3D, self]
		
		var result = space_state.intersect_ray(query)
		
		cardHolderID = 0
		
		
		if result:
			var resultPos = result.position
			# Placed on CardHolder
			if ((ownerID == 1 && result.collider.is_in_group(Placement+"1")) || 
				(ownerID == 2 && result.collider.is_in_group(Placement+"2"))):
				# Check Turn
				if ((ownerID == 1 && game_manager.turn == 2) ||
					(ownerID == 2 && game_manager.turn == 6) ||
					(game_manager.reactionTurn == ownerID && data.MagicCard)):
					global_position = result.collider.global_position
					global_position.y += 2
					draggingState = 1
					cardHolderID = int(result.collider.get_parent().name.substr(4))
			# Placed on Hand
			elif ((ownerID == 1 && result.collider.is_in_group("Hand1")) ||
				  (ownerID == 2 && result.collider.is_in_group("Hand2"))):
				global_position = result.position
				draggingState = 0
			# Placed on Grave
			elif ((ownerID == 1 && result.collider.is_in_group("grave1") && game_manager.turn == 4) ||
				  (ownerID == 2 && result.collider.is_in_group("grave2") && game_manager.turn == 8)):
				global_position = result.collider.global_position
				draggingState = 2
				if ownerID == 1: global_position.y += 1.6 + 0.06*game_manager.grave1.size()
				else: global_position.y += 1.6 + 0.06*game_manager.grave2.size()
				
			else:
				global_position = Vector3(resultPos.x, resultPos.y+1, resultPos.z)
				draggingState = 3
			var y
			if ownerID == 2:
				y = 180
			else:
				y = 0
			var x
			if (draggingState != 0 || draggingState == 3) and !isActivated:
				x = 0
			else:
				x = 180
			
			rotation_degrees = Vector3(x,y, 0)
