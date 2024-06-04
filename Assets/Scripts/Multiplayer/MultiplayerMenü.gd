extends Control

@onready var ipInput = $"Menü/IP"
@onready var portInput = $"Menü/Port"

@onready var file_name = $Lobby/FileName
@onready var load_button = $Lobby/LoadButton

@onready var loading = $"../Loading"

@onready var start_game = $"Lobby/Start Game"


var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@onready var menu = $"Menü"
@onready var lobby = $Lobby
@onready var player_count = $Lobby/PlayerCount

const MULTIPLAYER_GAME = "res://Assets/Scenes/MultiplayerGame.tscn"

@export var playerCount: int = 0

func quitLobby():
	pass


func _on_host_pressed():
	var ip: String = ipInput.text
	var port: int = int(portInput.text)
	
	peer.create_server(port, 2)
	multiplayer.multiplayer_peer = peer
	menu.visible=false
	lobby.visible=true
	start_game.visible = true
	
	
	multiplayer.peer_connected.connect(playerJoined)
	playerJoined(1)

func _on_join_pressed():
	var ip: String = ipInput.text
	var port: int = int(portInput.text)
	
	menu.visible=false
	lobby.visible=true
	
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	loading.visible=true
	multiplayer.connected_to_server.connect(connectedToServer)
	player_count.text = str(playerCount)+"/2"
	

func _on_start_game_pressed():
	if GlobalData.deck1!=null && GlobalData.deck2!=null:
		loadScene.rpc(MULTIPLAYER_GAME)
		

func playerJoined(id: int):
	playerCount+=1
	
	GlobalData.playerID[playerCount] = id
	
	player_count.text = str(playerCount)+"/2"



@rpc("any_peer", "call_local", "reliable")
func selectDeck(deck: Array):
	if multiplayer.get_remote_sender_id()==1:
		GlobalData.deck1 = deck
	else:
		GlobalData.deck2 = deck
	if GlobalData.deck1!=[] && GlobalData.deck2!=[]:
		start_game.disabled = false
	else:
		start_game.disabled = true

@rpc("authority", "call_local", "reliable")
func loadScene(scene: String):
	if multiplayer.is_server(): multiplayer.peer_connected.disconnect(playerJoined)
	GlobalData.sceneToLoad = scene
	get_tree().change_scene_to_packed(GlobalData.LOADING_SCREEN)

func connectedToServer():
	loading.visible=false


func _on_load_button_pressed():
	var filename: String = file_name.text
	if FileAccess.file_exists("res://Assets/Decks/"+filename+".deck"):
		var file = FileAccess.open("res://Assets/Decks/"+filename+".deck", FileAccess.READ)
		var data: Array = str_to_var(file.get_as_text())
		
		selectDeck.rpc_id(1, data)
		file.close()
		file = null


func _on_multiplayer_synchronizer_visibility_changed(for_peer):
	player_count.text = str(playerCount)+"/2"
