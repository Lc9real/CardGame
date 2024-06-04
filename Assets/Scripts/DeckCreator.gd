extends Control

var cards: Array[CardData]
@onready var all_cards = $"AllCards/AllCards/All Cards"
@onready var deckObj = $Deck/Deck/Deck
@onready var file_name = $FileName

const UI_MAGIC_CARD = preload("res://Assets/Scenes/uiMagicCard.tscn")
const UI_CREATURE_CARD = preload("res://Assets/Scenes/uiCreatureCard.tscn")

var mouseAboveDeck: bool

var deck: Array[int]


func _ready():
	# Get All Cards
	var dir = DirAccess.open("res://Assets/Cards/")
	for i in range(dir.get_directories().size()+1):
		cards.append(null)
	for folder in dir.get_directories():
		var dir2 = DirAccess.open("res://Assets/Cards/"+folder)
		for file in dir2.get_files():
			if file.ends_with(".tres"):
				var res: Resource = load("res://Assets/Cards/"+folder+"/"+file)
				if res.get_script() == load("res://Assets/Scripts/CardData.gd"):
					cards[res.cardID] = res
					var cardData = res
					var cardObj: Control
					if !cardData.MagicCard: cardObj = UI_CREATURE_CARD.instantiate()
					else: cardObj = UI_MAGIC_CARD.instantiate()
					cardObj.data = cardData
					cardObj.allCards = true
					cardObj.deck_creator = self
					all_cards.add_child(cardObj)


func _on_deck_mouse_entered():
	mouseAboveDeck = true


func _on_deck_mouse_exited():
	mouseAboveDeck = false


func addToDeck(id: int):
	deck.append(id)
	return deck.size()-1

func removeFromDeck(id: int):
	if deck.find(id) >= 0:
		deck.remove_at(deck.find(id))


func _on_save_pressed():
	var data: String = var_to_str(deck)
	var filename: String = file_name.text
	var file = FileAccess.open("res://Assets/Decks/"+filename+".deck", FileAccess.WRITE)
	file.store_string(data)
	file.close()
	file = null

func _on_load_pressed():
	var filename: String = file_name.text
	if FileAccess.file_exists("res://Assets/Decks/"+filename+".deck"):
		var file = FileAccess.open("res://Assets/Decks/"+filename+".deck", FileAccess.READ)
		deck = str_to_var(file.get_as_text())
		file.close()
		file = null
		for n in deckObj.get_children():
			deckObj.remove_child(n)
			n.queue_free()
		
		for card in deck:
			var data = cards[card]
			var cardCopy: Control
			if data.MagicCard: cardCopy = UI_MAGIC_CARD.instantiate()
			else: cardCopy = UI_CREATURE_CARD.instantiate()
			cardCopy.data = data
			cardCopy.allCards = false
			cardCopy.isDragging = false
			cardCopy.get_child(0).mouse_filter = Control.MOUSE_FILTER_PASS
			cardCopy.deck_creator = self
			deckObj.add_child(cardCopy)



func _on_clear_pressed():
	deck = []
	for n in deckObj.get_children():
			deckObj.remove_child(n)
			n.queue_free()


func _on_delete_pressed():
	var filename: String = file_name.text
	if FileAccess.file_exists("res://Assets/Decks/"+filename+".deck"):
		DirAccess.remove_absolute("res://Assets/Decks/"+filename+".deck")
