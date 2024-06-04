extends Control
class_name uiCard




@onready var _image = $HitBox/Image
@onready var _cardName = $HitBox/Name
@onready var _description = $HitBox/Description
@onready var _cardLevel = $HitBox/Level
const UI_CREATURE_CARD = preload("res://Assets/Scenes/uiCreatureCard.tscn")
const UI_MAGIC_CARD = preload("res://Assets/Scenes/uiMagicCard.tscn")


var deck_creator: Control
var isDragging: bool = false
var allCards: bool
var data: CardData



func _ready():
	_cardName.text = data.cardName
	_cardLevel.text = str(data.cardLevel)
	_image.texture = data.image
	_description.text = data.description

func _process(_delta):
	handleDragging()


func _input(event):
	if event is InputEventMouseButton && isDragging && !allCards:
		if event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
			isDragging = false
			if deck_creator.mouseAboveDeck:
				get_child(0).mouse_filter = Control.MOUSE_FILTER_PASS
				global_position = Vector2.ZERO
				reparent(deck_creator.deckObj, false)
				deck_creator.addToDeck(data.cardID)
			elif !allCards:
				deck_creator.removeFromDeck(data.cardID)
				queue_free()
			
			
			
			



func _on_hit_box_gui_input(event):
	if event is InputEventMouseButton:
		# Start Dragging
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if allCards:
				var cardCopy: Control
				if data.MagicCard: cardCopy = UI_MAGIC_CARD.instantiate()
				else: cardCopy = UI_CREATURE_CARD.instantiate()
				cardCopy.data = data
				cardCopy.allCards = false
				cardCopy.isDragging = true
				cardCopy.get_child(0).mouse_filter = Control.MOUSE_FILTER_IGNORE
				cardCopy.deck_creator = deck_creator
				deck_creator.add_child(cardCopy)
			else:
				isDragging = true
				get_child(0).mouse_filter = Control.MOUSE_FILTER_IGNORE
				reparent(deck_creator)

func handleDragging():
	if isDragging && !allCards:
		global_position = get_global_mouse_position()+Vector2(-75, -112.5)
