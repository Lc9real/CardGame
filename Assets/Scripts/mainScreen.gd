extends Control


@onready var deck_creator = %DeckCreator
@onready var main_menu = $MainMenu
@onready var singelplayer = $Singelplayer
@onready var file_name_1 = $Singelplayer/FileName1
@onready var file_name_2 = $Singelplayer/FileName2
@onready var start_game = $"Singelplayer/Start Game"
@onready var multiplayerMenü = $Multiplayer

const GAME = "res://Assets/Scenes/Game.tscn"

func _input(event):
	if Input.is_action_just_pressed("cancel"):
		if multiplayerMenü.visible:
			multiplayerMenü.quitLobby()
		
		main_menu.visible = true
		singelplayer.visible = false
		deck_creator.visible = false
		multiplayerMenü.visible = false

func _on_deck_editor_pressed():
	deck_creator.visible = !deck_creator.visible


func _on_singel_player_pressed():
	singelplayer.visible = true
	main_menu.visible = false

func _on_multiplayer_pressed():
	main_menu.visible = false
	multiplayerMenü.visible = true

func _on_options_pressed():
	pass # Replace with function body.


func _on_load_1_pressed():
	var filename: String = file_name_1.text
	if FileAccess.file_exists("res://Assets/Decks/"+filename+".deck"):
		var file = FileAccess.open("res://Assets/Decks/"+filename+".deck", FileAccess.READ)
		GlobalData.deck1 = str_to_var(file.get_as_text())
		file.close()
		file = null
		if GlobalData.deck1!=[] && GlobalData.deck2!=[]:
			start_game.disabled = false
		else:
			start_game.disabled = true

func _on_load_2_pressed():
	var filename: String = file_name_2.text
	if FileAccess.file_exists("res://Assets/Decks/"+filename+".deck"):
		var file = FileAccess.open("res://Assets/Decks/"+filename+".deck", FileAccess.READ)
		GlobalData.deck2 = str_to_var(file.get_as_text())
		file.close()
		file = null
		if GlobalData.deck1!=[] && GlobalData.deck2!=[]:
			start_game.disabled = false


func _on_start_game_pressed():
	if GlobalData.deck1!=null && GlobalData.deck2!=null:
		GlobalData.sceneToLoad = GAME
		get_tree().change_scene_to_packed(GlobalData.LOADING_SCREEN)
	else: 
		start_game.disabled = true
