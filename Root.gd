extends Node


# The URL we will connect to
export var websocket_url = "wss://ImportantCoordinatedDebugging.extremety1989.repl.co"

# Our WebSocketClient instance
var _client = null
#onready var ssl = preload("res://x509_certificate.crt")
onready var config = null
onready var my_username = $Main/start_menu/VBoxContainer/username
onready var JOINED_SERVER = 999
onready var NAMES = {}
onready var server_idx = 0
onready var delta = 0.0
var very_first = 0.0
var timer = 0
var spector_index = 0
var spectator_username = ""
var team = 0
var health = 100
var score_a = 0
var score_b = 0
var deaths = 0
var kills = 0
var game_mode = 0
var game_round = 0
var skin = 0
var current_weapon = 0
var weapon_1 = 0
var weapon_2 = 0
var weapon_3 = 0
var weapon_4 = 0
var weapon_5 = 0
var current_ammo = 0
var ammo_1 = 0
var ammo_2 = 0
var ammo_3 = 0
var ammo_4 = 0
var ammo_5 = 0

var test = StreamPeerBuffer.new()
var maps = ["Open Arena","Sniper Arena"]
var next_map = maps[0]
var extra_time = 0
func _unhandled_key_input(event):
	if not my_username.text == "":
		if event is InputEventKey:
			if JOINED_SERVER !=999:
				if event.scancode == 16777217 and event.pressed and $Main/in_game_menu.visible and not $Main/muted_players_menu.visible and not $Main/in_game_join_match.visible and not $Main/game_settings.visible and not $Main/in_game_choose_team.visible:
						Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _ready():
	var file = File.new()
	if file.file_exists("user://saved_settings.json"):
		file.open("user://saved_settings.json", File.READ)
		var content = file.get_var()
		if content:
			config = content
	file.close()

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	JOINED_SERVER = 999

func _connected(proto):
	print("conected ",proto)
	test = StreamPeerBuffer.new()
	test.put_u8(0)
	#test.put_string(config["my_username"].text.strip_edges())
	test.put_string(config["my_username"])
	_client.get_peer(1).put_packet(test.data_array)
	test.clear()
	set_process(true)



var action = 0
func _on_data():
	var packet = _client.get_peer(1).get_packet()
	var stream = StreamPeerBuffer.new()
	stream.set_data_array(packet)
	var code = stream.get_u8()
	var user_name = stream.get_string()
	if JOINED_SERVER == code:
		action = stream.get_u8()
		#Chose game_mode
		if action == 1:
				if get_node_or_null("Team_A/"+str(user_name)):
					if get_node_or_null("Team_A/"+str(user_name)).game_mode != 0:
						get_node_or_null("Team_A/"+str(user_name)).game_mode = stream.get_u8()
					stream.clear()
				elif get_node_or_null("Team_B/"+str(user_name)):
					if get_node_or_null("Team_B/"+str(user_name)).game_mode != 0:
						get_node_or_null("Team_B/"+str(user_name)).game_mode = stream.get_u8()
					stream.clear()
		#Change map
		if action == 2:
			var change_map = stream.get_u8()
			next_map = str(maps[change_map])
		#Joined match or move
		if action == 3:
			if not user_name in NAMES:
				NAMES.erase(user_name)
			if user_name != my_username.text and JOINED_SERVER != 999:
				var t = stream.get_u64()
				if get_node_or_null("Team_A/"+str(user_name)):
					get_node_or_null("Team_A/"+str(user_name)).translation = lerp(get_node_or_null("Team_A/"+str(user_name)).translation,Vector3(stream.get_float(),stream.get_float(),stream.get_float()),0.8)
					get_node_or_null("Team_A/"+str(user_name)).input_direction.x = stream.get_float()#input_direction x
					get_node_or_null("Team_A/"+str(user_name)).input_direction.y = stream.get_float()#input_direction y
					get_node_or_null("Team_A/"+str(user_name)).input_direction.z = stream.get_float()#input_direction z
					get_node_or_null("Team_A/"+str(user_name)).pivot.rotation.x = stream.get_float()#rotation x
					get_node_or_null("Team_A/"+str(user_name)).rotation.y = stream.get_float()#rotation y
					stream.clear()
				elif get_node_or_null("Team_B/"+str(user_name)):
					get_node_or_null("Team_B/"+str(user_name)).translation = lerp(get_node_or_null("Team_B/"+str(user_name)).translation,Vector3(stream.get_float(),stream.get_float(),stream.get_float()),0.8)
					get_node_or_null("Team_B/"+str(user_name)).input_direction.x = stream.get_float()#input_direction x
					get_node_or_null("Team_B/"+str(user_name)).input_direction.y = stream.get_float()#input_direction y
					get_node_or_null("Team_B/"+str(user_name)).input_direction.z = stream.get_float()#input_direction z
					get_node_or_null("Team_B/"+str(user_name)).pivot.rotation.x = stream.get_float()#rotation x
					get_node_or_null("Team_B/"+str(user_name)).rotation.y = stream.get_float()#rotation y
					stream.clear()
		#Mute/unmute player
		if action == 5:
			pass
		#game status/times etc..
		if action == 7:
				var user_skin = stream.get_u8()
				var game_who_is_the_first = stream.get_u64()
				var game_timer = stream.get_u16()
				var game_mode = stream.get_u8()
				var game_round = stream.get_u16()
				var game_team = stream.get_u8()
				if game_who_is_the_first < very_first:
					timer = game_timer
				else:
					timer = 306
				if game_team > 0:
					if game_team == 1 and $Team_A.get_child_count() <= $Team_B.get_child_count():
						if not get_node_or_null("Team_A/"+str(user_name)):
							if user_skin == 0:
								if get_node_or_null("Spectators/"+str(user_name)):
										get_node_or_null("Spectators/"+str(user_name)).timer = game_timer
										get_node_or_null("Spectators/"+str(user_name)).game_mode = game_mode
										get_node_or_null("Spectators/"+str(user_name)).game_round = game_round
										get_node_or_null("Spectators/"+str(user_name)).team = game_team
										get_node_or_null("Spectators/"+str(user_name)).score_a = stream.get_u8()
										get_node_or_null("Spectators/"+str(user_name)).score_b = stream.get_u8()
										get_node_or_null("Spectators/"+str(user_name)).health = stream.get_u8()
										get_node_or_null("Spectators/"+str(user_name)).deaths = stream.get_u16()
										get_node_or_null("Spectators/"+str(user_name)).kills = stream.get_u16()
										get_node_or_null("Spectators/"+str(user_name)).current_weapon = stream.get_u8()#current weapon
										get_node_or_null("Spectators/"+str(user_name)).weapon_1 = stream.get_u8()#weapon 1
										get_node_or_null("Spectators/"+str(user_name)).weapon_2 = stream.get_u8()#weapon 2
										get_node_or_null("Spectators/"+str(user_name)).weapon_3 = stream.get_u8()#weapon 3
										get_node_or_null("Spectators/"+str(user_name)).weapon_4 = stream.get_u8()#weapon 4
										get_node_or_null("Spectators/"+str(user_name)).weapon_5 = stream.get_u8()#weapon 5
										get_node_or_null("Spectators/"+str(user_name)).current_ammo = stream.get_u8()#current ammo
										get_node_or_null("Spectators/"+str(user_name)).ammo_1 = stream.get_u8()#ammo 1
										get_node_or_null("Spectators/"+str(user_name)).ammo_2 = stream.get_u8()#ammo 2
										get_node_or_null("Spectators/"+str(user_name)).ammo_3 = stream.get_u8()#ammo 3
										get_node_or_null("Spectators/"+str(user_name)).ammo_4 = stream.get_u8()#ammo 4
										get_node_or_null("Spectators/"+str(user_name)).ammo_5 = stream.get_u8()#ammo 5
										$Team_A.add_child(get_node_or_null("Spectators/"+str(user_name)))
										$Spectators.remove_child(get_node_or_null("Spectators/"+str(user_name)))
								else:
									var other = null
									if user_name == my_username.text:
										other = load("res://Me.tscn").instance()
										other.name = str(user_name)
										other.set_script(load("Me.gd"))
									else:
										other = load("res://Other.tscn").instance()
										other.name = str(user_name)
										other.set_script(load("Other.gd"))
									NAMES[user_name] = false
									other.timer = game_timer
									other.game_mode = game_mode
									other.game_round = game_round
									other.team = game_team
									other.score_a = stream.get_u8()
									other.score_b = stream.get_u8()
									other.health = stream.get_u8()
									other.deaths = stream.get_u16()
									other.kills = stream.get_u16()
									other.current_weapon = stream.get_u8()#current weapon
									other.weapon_1 = stream.get_u8()#weapon 1
									other.weapon_2 = stream.get_u8()#weapon 2
									other.weapon_3 = stream.get_u8()#weapon 3
									other.weapon_4 = stream.get_u8()#weapon 4
									other.weapon_5 = stream.get_u8()#weapon 5
									other.current_ammo = stream.get_u8()#current ammo
									other.ammo_1 = stream.get_u8()#ammo 1
									other.ammo_2 = stream.get_u8()#ammo 2
									other.ammo_3 = stream.get_u8()#ammo 3
									other.ammo_4 = stream.get_u8()#ammo 4
									other.ammo_5 = stream.get_u8()#ammo 5
									stream.clear()
									$Team_A.add_child(other)
						else:
							get_node_or_null("Team_A/"+str(user_name)).afk_counter = OS.get_system_time_msecs()
							get_node_or_null("Team_A/"+str(user_name)).timer = game_timer
							get_node_or_null("Team_A/"+str(user_name)).game_mode = game_mode
							get_node_or_null("Team_A/"+str(user_name)).game_round = game_round
							get_node_or_null("Team_A/"+str(user_name)).team = game_team
							get_node_or_null("Team_A/"+str(user_name)).score_a = stream.get_u8()
							get_node_or_null("Team_A/"+str(user_name)).score_b = stream.get_u8()
							get_node_or_null("Team_A/"+str(user_name)).health = stream.get_u8()
							get_node_or_null("Team_A/"+str(user_name)).deaths = stream.get_u16()
							get_node_or_null("Team_A/"+str(user_name)).kills = stream.get_u16()
							get_node_or_null("Team_A/"+str(user_name)).current_weapon = stream.get_u8()#current weapon
							get_node_or_null("Team_A/"+str(user_name)).weapon_1 = stream.get_u8()#weapon 1
							get_node_or_null("Team_A/"+str(user_name)).weapon_2 = stream.get_u8()#weapon 2
							get_node_or_null("Team_A/"+str(user_name)).weapon_3 = stream.get_u8()#weapon 3
							get_node_or_null("Team_A/"+str(user_name)).weapon_4 = stream.get_u8()#weapon 4
							get_node_or_null("Team_A/"+str(user_name)).weapon_5 = stream.get_u8()#weapon 5
							get_node_or_null("Team_A/"+str(user_name)).current_ammo = stream.get_u8()#current ammo
							get_node_or_null("Team_A/"+str(user_name)).ammo_1 = stream.get_u8()#ammo 1
							get_node_or_null("Team_A/"+str(user_name)).ammo_2 = stream.get_u8()#ammo 2
							get_node_or_null("Team_A/"+str(user_name)).ammo_3 = stream.get_u8()#ammo 3
							get_node_or_null("Team_A/"+str(user_name)).ammo_4 = stream.get_u8()#ammo 4
							get_node_or_null("Team_A/"+str(user_name)).ammo_5 = stream.get_u8()#ammo 5
							stream.clear()
					elif game_team == 2 and $Team_B.get_child_count() <= $Team_A.get_child_count():
						if not get_node_or_null("Team_B/"+str(user_name)):
							if user_skin == 0:
								if get_node_or_null("Spectators/"+str(user_name)):
									get_node_or_null("Spectators/"+str(user_name)).health = 100
									get_node_or_null("Spectators/"+str(user_name)).timer = game_timer
									get_node_or_null("Spectators/"+str(user_name)).game_mode = game_mode
									get_node_or_null("Spectators/"+str(user_name)).game_round = game_round
									get_node_or_null("Spectators/"+str(user_name)).team = game_team
									get_node_or_null("Spectators/"+str(user_name)).timer = game_timer
									get_node_or_null("Spectators/"+str(user_name)).game_mode = game_mode
									get_node_or_null("Spectators/"+str(user_name)).game_round = game_round
									get_node_or_null("Spectators/"+str(user_name)).team = game_team
									get_node_or_null("Spectators/"+str(user_name)).score_a = stream.get_u8()
									get_node_or_null("Spectators/"+str(user_name)).score_b = stream.get_u8()
									get_node_or_null("Spectators/"+str(user_name)).health = stream.get_u8()
									get_node_or_null("Spectators/"+str(user_name)).deaths = stream.get_u16()
									get_node_or_null("Spectators/"+str(user_name)).kills = stream.get_u16()
									get_node_or_null("Spectators/"+str(user_name)).current_weapon = stream.get_u8()#current weapon
									get_node_or_null("Spectators/"+str(user_name)).weapon_1 = stream.get_u8()#weapon 1
									get_node_or_null("Spectators/"+str(user_name)).weapon_2 = stream.get_u8()#weapon 2
									get_node_or_null("Spectators/"+str(user_name)).weapon_3 = stream.get_u8()#weapon 3
									get_node_or_null("Spectators/"+str(user_name)).weapon_4 = stream.get_u8()#weapon 4
									get_node_or_null("Spectators/"+str(user_name)).weapon_5 = stream.get_u8()#weapon 5
									get_node_or_null("Spectators/"+str(user_name)).current_ammo = stream.get_u8()#current ammo
									get_node_or_null("Spectators/"+str(user_name)).ammo_1 = stream.get_u8()#ammo 1
									get_node_or_null("Spectators/"+str(user_name)).ammo_2 = stream.get_u8()#ammo 2
									get_node_or_null("Spectators/"+str(user_name)).ammo_3 = stream.get_u8()#ammo 3
									get_node_or_null("Spectators/"+str(user_name)).ammo_4 = stream.get_u8()#ammo 4
									get_node_or_null("Spectators/"+str(user_name)).ammo_5 = stream.get_u8()#ammo 5
									$Team_B.add_child(get_node_or_null("Spectators/"+str(user_name)))
									$Spectators.remove_child(get_node_or_null("Spectators/"+str(user_name)))
								#user was not spectating he joins the team
								else:
									var other = null
									if user_name == my_username.text:
										other = load("res://Me.tscn").instance()
										other.name = str(user_name)
										other.set_script(load("Me.gd"))
									else:
										other = load("res://Other.tscn").instance()
										other.name = str(user_name)
										other.set_script(load("Other.gd"))
									NAMES[user_name] = false
									other.timer = game_timer
									other.game_mode = game_mode
									other.game_round = game_round
									other.team = game_team
									other.score_a = stream.get_u8()
									other.score_b = stream.get_u8()
									other.health = stream.get_u8()
									other.deaths = stream.get_u16()
									other.kills = stream.get_u16()
									other.current_weapon = stream.get_u8()#current weapon
									other.weapon_1 = stream.get_u8()#weapon 1
									other.weapon_2 = stream.get_u8()#weapon 2
									other.weapon_3 = stream.get_u8()#weapon 3
									other.weapon_4 = stream.get_u8()#weapon 4
									other.weapon_5 = stream.get_u8()#weapon 5
									other.current_ammo = stream.get_u8()#current ammo
									other.ammo_1 = stream.get_u8()#ammo 1
									other.ammo_2 = stream.get_u8()#ammo 2
									other.ammo_3 = stream.get_u8()#ammo 3
									other.ammo_4 = stream.get_u8()#ammo 4
									other.ammo_5 = stream.get_u8()#ammo 5
									stream.clear()
									$Team_B.add_child(other)
						else:
							get_node_or_null("Team_B/"+str(user_name)).afk_counter = OS.get_system_time_msecs()
							get_node_or_null("Team_B/"+str(user_name)).timer = game_timer
							get_node_or_null("Team_B/"+str(user_name)).game_mode = game_mode
							get_node_or_null("Team_B/"+str(user_name)).game_round = game_round
							get_node_or_null("Team_B/"+str(user_name)).team = game_team
							get_node_or_null("Team_B/"+str(user_name)).score_a = stream.get_u8()
							get_node_or_null("Team_B/"+str(user_name)).score_b = stream.get_u8()
							get_node_or_null("Team_B/"+str(user_name)).health = stream.get_u8()
							get_node_or_null("Team_B/"+str(user_name)).deaths = stream.get_u16()
							get_node_or_null("Team_B/"+str(user_name)).kills = stream.get_u16()
							get_node_or_null("Team_B/"+str(user_name)).current_weapon = stream.get_u8()#current weapon
							get_node_or_null("Team_B/"+str(user_name)).weapon_1 = stream.get_u8()#weapon 1
							get_node_or_null("Team_B/"+str(user_name)).weapon_2 = stream.get_u8()#weapon 2
							get_node_or_null("Team_B/"+str(user_name)).weapon_3 = stream.get_u8()#weapon 3
							get_node_or_null("Team_B/"+str(user_name)).weapon_4 = stream.get_u8()#weapon 4
							get_node_or_null("Team_B/"+str(user_name)).weapon_5 = stream.get_u8()#weapon 5
							get_node_or_null("Team_B/"+str(user_name)).current_ammo = stream.get_u8()#current ammo
							get_node_or_null("Team_B/"+str(user_name)).ammo_1 = stream.get_u8()#ammo 1
							get_node_or_null("Team_B/"+str(user_name)).ammo_2 = stream.get_u8()#ammo 2
							get_node_or_null("Team_B/"+str(user_name)).ammo_3 = stream.get_u8()#ammo 3
							get_node_or_null("Team_B/"+str(user_name)).ammo_4 = stream.get_u8()#ammo 4
							get_node_or_null("Team_B/"+str(user_name)).ammo_5 = stream.get_u8()#ammo 5
							stream.clear()
				else:
					if get_node_or_null("Team_A/"+str(user_name)):
						if not get_node_or_null("Spectators/"+str(user_name)):
							get_node_or_null("Spectators/"+str(user_name)).add_child(get_node_or_null("Team_A/"+str(user_name)))
						$Team_A.remove_child(get_node_or_null("Team_A/"+str(user_name)))
					elif get_node_or_null("Team_B/"+str(user_name)):
						if not get_node_or_null("Spectators/"+str(user_name)):
							get_node_or_null("Spectators/"+str(user_name)).add_child(get_node_or_null("Team_B/"+str(user_name)))
						$Team_B.remove_child(get_node_or_null("Team_B/"+str(user_name)))
				stream.clear()
		#fire
		if action == 8:
			if get_node_or_null("Team_A/"+str(user_name)):
				get_node_or_null("Team_A/"+str(user_name)).fire()
				get_node_or_null("Team_A/"+str(user_name)).muzzle.x = stream.get_float()#position x
				get_node_or_null("Team_A/"+str(user_name)).muzzle.y = stream.get_float()#position y
				get_node_or_null("Team_A/"+str(user_name)).muzzle.z = stream.get_float()#position z
				get_node_or_null("Team_B/"+str(user_name)).fire()
			if get_node_or_null("Team_B/"+str(user_name)):
				get_node_or_null("Team_B/"+str(user_name)).muzzle.x = stream.get_float()#position x
				get_node_or_null("Team_B/"+str(user_name)).muzzle.y = stream.get_float()#position y
				get_node_or_null("Team_B/"+str(user_name)).muzzle.z = stream.get_float()#position z
			stream.clear()
	if code == 0:
		if user_name != "":
			my_username.text = user_name
			$Main/server_menu.visible = true
			$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer/ScrollContainer/Servers.unselect_all()
			if $Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer/ScrollContainer/Servers.get_item_count() < 1:
				$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer/ScrollContainer/Servers.connect("item_selected",self,"server_selected",[$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer/ScrollContainer/Servers])
				for i in range(1,11):
					$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer/ScrollContainer/Servers.add_item(("Server "+str(i)))
			if $Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer2/ScrollContainer/ItemList and $Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer2/ScrollContainer/ItemList.get_item_count() > 0:
				for i in range($Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer2/ScrollContainer/ItemList.get_item_count()):
					$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer2/ScrollContainer/ItemList.remove_item(i)
			$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer2/ScrollContainer/ItemList.unselect_all()
		else:
			$Main/start_menu/VBoxContainer/error_message.text = "username already in use"

	elif code == 1 and stream.get_size() > 1:
		#see player names
		$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer2/ScrollContainer/ItemList.clear()
		if not user_name in NAMES:
			NAMES[user_name] = false
		if NAMES.size() > 0:
			$Main/start_menu.visible = false
			for i in NAMES:
				$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer2/ScrollContainer/ItemList.add_item(i)
	elif code == 1:
				$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer2/ScrollContainer/ItemList.clear()
				$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer2/ScrollContainer/ItemList.add_item("no players")
	elif code == 2 and stream.get_size() > 1:
		#first join
		$Main/in_game_time.visible = true
		$Main/server_menu.visible = false
		$Main/in_game_join_match.visible = true
		very_first = OS.get_system_time_msecs()
		if user_name == my_username.text and JOINED_SERVER == 999:
			JOINED_SERVER = server_idx+100
			NAMES[user_name] = false

func _process(_delta):
	if _client:
		_client.poll()
		if JOINED_SERVER != 999 :
			delta += _delta
			if delta > 0.1000:
				if get_node_or_null("Team_A/"+str(my_username.text)) and get_node_or_null("Team_A/"+str(my_username.text)).team == 1:
					test.put_u8(JOINED_SERVER)#code is now server_id
					test.put_string(my_username.text)
					test.put_u8(7)#action
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).skin)#character skin
					test.put_u64(very_first)
					test.put_u16(get_node_or_null("Team_A/"+str(my_username.text)).timer)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).game_mode)
					test.put_u16(get_node_or_null("Team_A/"+str(my_username.text)).game_round)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).team)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).score_a)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).score_b)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).health)
					test.put_u16(get_node_or_null("Team_A/"+str(my_username.text)).deaths)
					test.put_u16(get_node_or_null("Team_A/"+str(my_username.text)).kills)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).current_weapon)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).weapon_1)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).weapon_2)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).weapon_3)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).weapon_4)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).weapon_5)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).current_ammo)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).ammo_1)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).ammo_2)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).ammo_3)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).ammo_4)
					test.put_u8(get_node_or_null("Team_A/"+str(my_username.text)).ammo_5)
					_client.get_peer(1).put_packet(test.data_array)
					test.clear()
				elif get_node_or_null("Team_B/"+str(my_username.text)) and get_node_or_null("Team_B/"+str(my_username.text)).team == 2:
					test.put_u8(JOINED_SERVER)#code is now server_id
					test.put_string(my_username.text)
					test.put_u8(7)#action
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).skin)#character skin
					test.put_u64(very_first)
					test.put_u16(get_node_or_null("Team_B/"+str(my_username.text)).timer)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).game_mode)
					test.put_u16(get_node_or_null("Team_B/"+str(my_username.text)).game_round)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).team)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).score_a)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).score_b)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).health)
					test.put_u16(get_node_or_null("Team_B/"+str(my_username.text)).deaths)
					test.put_u16(get_node_or_null("Team_B/"+str(my_username.text)).kills)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).current_weapon)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).weapon_1)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).weapon_2)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).weapon_3)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).weapon_4)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).weapon_5)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).current_ammo)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).ammo_1)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).ammo_2)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).ammo_3)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).ammo_4)
					test.put_u8(get_node_or_null("Team_B/"+str(my_username.text)).ammo_5)
					_client.get_peer(1).put_packet(test.data_array)
					test.clear()
				elif not get_node_or_null("Spectators/"+str(my_username.text)):
					test.put_u8(JOINED_SERVER)#code is now server_id
					test.put_string(my_username.text)
					test.put_u8(7)#action
					test.put_u8(skin)#character skin
					test.put_u64(very_first)
					test.put_u16(timer)
					test.put_u8(game_mode)
					test.put_u16(game_round)
					test.put_u8(team)
					test.put_u8(score_a)
					test.put_u8(score_b)
					test.put_u8(health)
					test.put_u16(deaths)
					test.put_u16(kills)
					test.put_u8(current_weapon)
					test.put_u8(weapon_1)
					test.put_u8(weapon_2)
					test.put_u8(weapon_3)
					test.put_u8(weapon_4)
					test.put_u8(weapon_5)
					test.put_u8(current_ammo)
					test.put_u8(ammo_1)
					test.put_u8(ammo_2)
					test.put_u8(ammo_3)
					test.put_u8(ammo_4)
					test.put_u8(ammo_5)
					_client.get_peer(1).put_packet(test.data_array)
					test.clear()

			if delta > 0.1000/0.10:
				#fire
	#			if team > 0:
	#				test.put_u8(JOINED_SERVER)#code is now server_id
	#				test.put_u8(8)#action
	#				test.put_string(my_username.text)
	#				test.put_float(state.x)
	#				test.put_float(state.y)
	#				test.put_float(state.z)
	#				_client.get_peer(1).put_packet(test.data_array)
	#				test.clear()

				#emit movements of player
				test.put_u8(JOINED_SERVER)#code is now server_id
				test.put_string(my_username.text)
				test.put_u8(3)#action
				test.put_u64(OS.get_system_time_msecs())
				if get_node_or_null("Team_A/"+str(my_username.text)) and get_node_or_null("Team_A/"+str(my_username.text)).team == 1:
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).translation.x)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).translation.y)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).translation.z)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).input_direction.x)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).input_direction.y)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).input_direction.z)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).pivot.rotation.x)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).rotation.y)
					_client.get_peer(1).put_packet(test.data_array)
					test.clear()
				elif get_node_or_null("Team_B/"+str(my_username.text)) and get_node_or_null("Team_B/"+str(my_username.text)).team == 2:
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).translation.x)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).translation.y)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).translation.z)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).input_direction.x)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).input_direction.y)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).input_direction.z)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).pivot.rotation.x)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).rotation.y)
					_client.get_peer(1).put_packet(test.data_array)
					test.clear()


			if delta > 1.000:
				delta = 0
				if timer > 0:
					timer-= 1
				#when you planned something with timer
#				if timer < extra_time:
#					timer = extra_time - timer
#				if timer > extra_time:
#					timer = extra_time
				
				if  timer - 6 > 0:
					if timer == 300:
						$Main/in_game_time/VBoxContainer/top_time.text = "GO"
					else:
						$Main/in_game_time/VBoxContainer2/bottom_time.text = str(timer / 60) + ":" + str(timer%60)
				elif timer - 6 == 0:
					timer = 306
				else:
					$Main/in_game_time/VBoxContainer2/bottom_time.text = str(timer)




func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if JOINED_SERVER != 999:
			test.put_u8(JOINED_SERVER)#code is now server_id
			test.put_u8(6)#action
			test.put_string(my_username.text)
			_client.get_peer(1).put_packet(test.data_array)
			test.clear()
		set_process(false)


func connect_to_server():
		if not my_username.text == "" and my_username.text.length() > 3 and my_username.text.length() < 24:
			_client = WebSocketClient.new()
			 # Connect base signals to get notified of connection open, close, and errors.
			_client.connect("connection_closed", self, "_closed")
			_client.connect("connection_error", self, "_closed")
			_client.connect("connection_established", self, "_connected")
			_client.connect("data_received", self, "_on_data")
#			_client.trusted_ssl_certificate = ssl
			var err = _client.connect_to_url(websocket_url)
			if err != OK:
				print("Unable to connect")
				_client = null
				set_process(false)

func exit():
	_client.disconnect_from_host()

func join():
	test = StreamPeerBuffer.new()
	test.put_u8(2)
	test.put_u8(server_idx)
	test.put_string(my_username.text.strip_edges())
	_client.get_peer(1).put_packet(test.data_array)
	test.clear()
