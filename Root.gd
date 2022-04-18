extends Node
onready var keys = {
	65: "A",
	66: "B",
	67: "C",
	68: "D",
	69: "E",
	70: "F",
	71: "G",
	72: "H",
	73: "I",
	74:"J",
	75:"K",
	76:"L",
	77:"M",
	78:"N",
	79:"O",
	80:"P",
	81:"Q",
	82: "R",
	83: "S",
	84:"T",
	85:"U",
	86:"V",
	87:"W",
	88:"X",
	89:"Y",
	90:"Z",
	16777218:"Tab",
	16777237:"Shift",
	16777238:"Ctrl",
	16777219:"Shift-Tab",
	32: "Space",
	1: "Left Mouse",
	2: "Right Mouse",
	3: "Middle Mouse",
	4: "Wheel Up",
	5: "Wheel Down",
	16777221: "Enter",
	16777231: "Left Arrow",
	16777233: "Right Arrow",
	16777232: "Up Arrow",
	16777234: "Down Arrow"
}
export onready var data_to_save = {
	"mouse_sensitivity": $Main/game_settings/VBoxContainer/VBoxContainer4/HBoxContainer/HSlider.value,
}
onready var default_data_to_save = {	
	  "mouse_sensitivity": 0.01,
}
export var inputs = {	
	"forward": false,
	"backward": false,
	"left": false,
	"right": false,
	"jump": false,
	"fire": false,
	"aim": false,
	"fast_motion": false,
	"drop": false,
	"pick": false,
	"use": false,
	"next_weapon":false,
	"previous_weapon":false,
}

# The URL we will connect to
export var websocket_url = "wss://ImportantCoordinatedDebugging.extremety1989.repl.co"

# Our WebSocketClient instance
var _client = null
#onready var ssl = preload("res://x509_certificate.crt")
onready var reset_data_to_save = null
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
func _input(event):
	if not my_username.text == "":
		if event is InputEventMouseMotion:
			inputs["mouse_sensitivity"] = data_to_save["mouse_sensitivity"]
		if event is InputEventMouseButton and JOINED_SERVER !=999 and get_node_or_null("Team_A/"+str(my_username.text)) or get_node_or_null("Team_B/"+str(my_username.text)):
			if event.button_index == 1 and event.pressed  and not $Main/chat_input.visible:
				inputs["fire"] = true
			elif event.button_index == 1 and not event.pressed  and not $Main/chat_input.visible:
				inputs["fire"] = false
			if event.button_index == 2 and event.pressed  and not $Main/chat_input.visible:
				if not inputs["aim"]:
					inputs["aim"] = true
				else:
					inputs["aim"] = false
			if event.button_index == 16777233 and event.pressed  and not $Main/chat_input.visible:
					inputs["next_weapon"] = true
			if event.button_index == 16777231 and event.pressed  and not $Main/chat_input.visible:
					inputs["previous_weapon"] = true
			if event.button_index == 69 and event.pressed  and not $Main/chat_input.visible:
					inputs["use"] = true
			if event.button_index == 71 and event.pressed  and not $Main/chat_input.visible:
					inputs["drop"] = true
			if event.button_index == 16777237 and event.pressed  and not $Main/chat_input.visible:
					inputs["fast_motion"] = true
			if event.button_index == 32 and event.pressed  and not $Main/chat_input.visible:
					inputs["jump"] = true

		if event is InputEventKey:
			if JOINED_SERVER !=999:
				if event.scancode == 16777218 and event.pressed and not $Main/in_game_menu.visible and not $Main/muted_players_menu.visible and not $Main/in_game_join_match.visible and not $Main/game_settings.visible and not $Main/in_game_choose_team.visible:
					for i in $Main/in_game_players_info/HBoxContainer/VBoxContainer/PanelContainer.get_children():
							$Main/in_game_players_info/HBoxContainer/VBoxContainer/PanelContainer.remove_child(i)
					if $Team_A.get_child_count() > 0:
						for child in $Team_A.get_children():
							var label = Label.new()
							label.text += str(child.name)
							$Main/in_game_players_info/HBoxContainer/VBoxContainer/PanelContainer.add_child(label)
					if $Team_B.get_child_count() > 0:
						for child in $Team_B.get_children():
							var label = Label.new()
							label.text += str(child.name)
							$Main/in_game_players_info/HBoxContainer/VBoxContainer2/PanelContainer.add_child(label)
					$Main/in_game_players_info.show()
				elif event.scancode == 16777218 and not event.pressed and not $Main/in_game_menu.visible and not $Main/muted_players_menu.visible and not $Main/in_game_join_match.visible and not $Main/game_settings.visible and not $Main/in_game_choose_team.visible:
					$Main/in_game_players_info.hide()
				if event.scancode == 16777217 and event.pressed and not $Main/in_game_menu.visible and not $Main/muted_players_menu.visible and not $Main/in_game_join_match.visible and not $Main/game_settings.visible and not $Main/in_game_choose_team.visible:
						$Main/in_game_menu.visible = true
						$Main/in_game_time.visible = false
						Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
						if NAMES.size() < 2:
							$Main/in_game_menu/VBoxContainer/spectate.hide()
							$Main/in_game_menu/VBoxContainer/open_muted_players_menu.hide()
						else:
							$Main/in_game_menu/VBoxContainer/spectate.show()
							$Main/in_game_menu/VBoxContainer/open_muted_players_menu.show()
				elif event.scancode == 16777217 and event.pressed and $Main/in_game_menu.visible and not $Main/muted_players_menu.visible and not $Main/in_game_join_match.visible and not $Main/game_settings.visible and not $Main/in_game_choose_team.visible:
						$Main/in_game_menu.visible = false
						$Main/in_game_time.visible = true
						Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				if $Main/chat_input.visible:
					$Main/chat_input/HBoxContainer/LineEdit.grab_focus()
				if event.scancode == 1 and event.pressed  and not $Main/chat_input.visible:
					inputs["fire"] = true
				if event.scancode == 2 and event.pressed  and not $Main/chat_input.visible:
					if not inputs["aim"]:
						inputs["aim"] = true
					else:
						inputs["aim"] = false
				if event.scancode == 16777233 and event.pressed  and not $Main/chat_input.visible:
						inputs["next_weapon"] = true
				elif event.scancode == 16777233 and not event.pressed  and not $Main/chat_input.visible:
						inputs["next_weapon"] = false
				if event.scancode == 16777231 and event.pressed  and not $Main/chat_input.visible:
						inputs["previous_weapon"] = true
				elif event.scancode == 16777231 and not event.pressed  and not $Main/chat_input.visible:
						inputs["previous_weapon"] = false
				if event.scancode == 69 and event.pressed  and not $Main/chat_input.visible:
						inputs["use"] = true
				elif event.scancode == 69 and not event.pressed  and not $Main/chat_input.visible:
						inputs["drop"] = true
				if event.scancode == 71 and event.pressed  and not $Main/chat_input.visible:
						inputs["drop"] = true
				elif event.scancode == 71 and not event.pressed  and not $Main/chat_input.visible:
						inputs["drop"] = false
				if event.scancode == 16777237 and event.pressed  and not $Main/chat_input.visible:
						inputs["fast_motion"] = true
				elif event.scancode == 16777237 and not event.pressed  and not $Main/chat_input.visible:
						inputs["fast_motion"] = false

				if event.pressed and event.scancode == 32  and not $Main/chat_input.visible:
						inputs["jump"] = true
				elif not event.pressed and event.scancode == 32  and not $Main/chat_input.visible:
						inputs["jump"] = false
				if spectator_username != "" and event.pressed and event.scancode == 32 and not get_node_or_null("Team_A/"+str(my_username.text)) and get_node_or_null("Team_B/"+str(my_username.text)):
						for name in NAMES:
							if name != my_username.text and name != spectator_username:
								spectator_username = str(name)
								break

				if event.pressed and event.scancode == 90 and not $Main/chat_input.visible:
						inputs["forward"] = true
				elif not event.pressed and event.scancode == 90  and not $Main/chat_input.visible:
						inputs["forward"] = false
				if event.pressed and event.scancode == 83  and not $Main/chat_input.visible:
						inputs["backward"] = true
				elif not event.pressed and event.scancode == 83  and not $Main/chat_input.visible:
						inputs["backward"] = false
				if event.pressed and event.scancode == 81  and not $Main/chat_input.visible:
						inputs["left"] = true
				elif not event.pressed and event.scancode == 81  and not $Main/chat_input.visible:
						inputs["left"] = false
				if event.pressed and event.scancode == 68 and not $Main/chat_input.visible:
						inputs["right"] = true
				elif not event.pressed and event.scancode == 68  and not $Main/chat_input.visible:
						inputs["right"] = false
				if event.pressed and event.scancode == 89 and not $Main/chat_input.visible:
					$Main/chat_input.visible = true		
					$Main/chat_input/HBoxContainer/Label.text = my_username.text + ":"
				elif event.pressed and  event.scancode == 16777221  and $Main/chat_input.visible:
					if $Main/chat_input/HBoxContainer/LineEdit.text !="" and len($Main/chat_input/HBoxContainer/LineEdit.text) < 101:
						test = StreamPeerBuffer.new()
						test.put_u8(JOINED_SERVER)
						test.put_u8(4)
						test.put_string(my_username.text)
						test.put_string($Main/chat_input/HBoxContainer/LineEdit.text)
						_client.get_peer(1).put_packet(test.data_array)
						test.clear()
						$Main/chat_input/HBoxContainer/LineEdit.text = ""
					$Main/chat_input/HBoxContainer/LineEdit.release_focus()
					$Main/chat_input.visible = false



func _ready():
	var file = File.new()
	if file.file_exists("user://saved_settings.json"):
		file.open("user://saved_settings.json", File.READ)
		var content = file.get_var()
		if content:
			$Main/game_settings/VBoxContainer/VBoxContainer4/HBoxContainer/HSlider.value = content["mouse_sensitivity"]
			data_to_save = content
		else:
			data_to_save = default_data_to_save
	else:
		file.open("user://saved_settings.json", File.WRITE)
		data_to_save = default_data_to_save
		file.store_var(data_to_save)
	file.close()

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	JOINED_SERVER = 999
	NAMES = {}
	$Main/in_game_time.visible = false
	$Main/start_menu.visible = true
	$Main/chat_box.visible = false
	$Main/chat_input.visible = false

func _connected(proto):
	print("conected ",proto)
	test = StreamPeerBuffer.new()
	test.put_u8(0)
	test.put_string(my_username.text.strip_edges())
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
					get_node_or_null("Team_A/"+str(user_name)).position = Vector3(stream.get_float(),stream.get_float(),stream.get_float())
					get_node_or_null("Team_A/"+str(user_name)).velocity.x = stream.get_float()#velocity x
					get_node_or_null("Team_A/"+str(user_name)).velocity.y = stream.get_float()#velocity y
					get_node_or_null("Team_A/"+str(user_name)).velocity.z = stream.get_float()#velocity z
					get_node_or_null("Team_A/"+str(user_name)).pivot.rotation.x = stream.get_float()#rotation x
					get_node_or_null("Team_A/"+str(user_name)).rotation.y = stream.get_float()#rotation y
					stream.clear()
				elif get_node_or_null("Team_B/"+str(user_name)):
					get_node_or_null("Team_B/"+str(user_name)).position = Vector3(stream.get_float(),stream.get_float(),stream.get_float())
					get_node_or_null("Team_B/"+str(user_name)).velocity.x = stream.get_float()#velocity x
					get_node_or_null("Team_B/"+str(user_name)).velocity.y = stream.get_float()#velocity y
					get_node_or_null("Team_B/"+str(user_name)).velocity.z = stream.get_float()#velocity z
					get_node_or_null("Team_B/"+str(user_name)).pivot.rotation.x = stream.get_float()#rotation x
					get_node_or_null("Team_B/"+str(user_name)).rotation.y = stream.get_float()#rotation y
					stream.clear()
		#chat output
		if action == 4:
			var message = stream.get_string()
			if user_name in NAMES and not NAMES[user_name]:
				if user_name == my_username.text:
					$Main/chat_box/RichTextLabel.bbcode_text += '[color=yellow]'
					$Main/chat_box/RichTextLabel.bbcode_text += '[you]: '
					$Main/chat_box/RichTextLabel.bbcode_text += message
					$Main/chat_box/RichTextLabel.bbcode_text += '[/color]'
				else:
					$Main/chat_box/RichTextLabel.bbcode_text += '['+user_name+']: '
					$Main/chat_box/RichTextLabel.bbcode_text += message
				$Main/chat_box/RichTextLabel.bbcode_text += '\n'
			stream.clear()
		#Mute/unmute player
		if action == 5:
			pass
		#player left the game
		if action == 6:
			if user_name != my_username.text:
				if user_name in NAMES:
					NAMES.erase(user_name)
				$Players.remove_child(user_name)
				$Main/chat_box/RichTextLabel.bbcode_text += '[color=cyan]'
				$Main/chat_box/RichTextLabel.bbcode_text += '[SYSTEM]: '
				$Main/chat_box/RichTextLabel.bbcode_text += user_name + ' left the game.'
				$Main/chat_box/RichTextLabel.bbcode_text += '[/color]'
				$Main/chat_box/RichTextLabel.bbcode_text += '\n'
			stream.clear()
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
										$smooth_camera.target = other.get_node_or_null("camera_root").get_node_or_null("Position3D")
									else:
										other = load("res://Other.tscn").instance()
										other.name = str(user_name)
										other.set_script(load("Other.gd"))
										var node = get_node_or_null("Main/chat_box/RichTextLabel")
										node.bbcode_text += '[color=green]'
										node.bbcode_text += "[SYSTEM]: "
										node.bbcode_text += str(user_name)+' joined the game.'
										node.bbcode_text += '[/color]'
										node.bbcode_text += '\n'
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
								else:
									var other = null
									if user_name == my_username.text:
										other = load("res://Me.tscn").instance()
										other.name = str(user_name)
										other.set_script(load("Me.gd"))
										$smooth_camera.target = other.get_node_or_null("camera_root").get_node_or_null("Position3D")
									else:
										other = load("res://Other.tscn").instance()
										other.name = str(user_name)
										other.set_script(load("Other.gd"))
										var node = get_node_or_null("Main/chat_box/RichTextLabel")
										node.bbcode_text += '[color=green]'
										node.bbcode_text += "[SYSTEM]: "
										node.bbcode_text += str(user_name)+' joined the game.'
										node.bbcode_text += '[/color]'
										node.bbcode_text += '\n'
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
			print("8")
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
		$Main/chat_box.visible = true
		$Main/in_game_join_match.visible = true
		very_first = OS.get_system_time_msecs()
		if user_name == my_username.text and JOINED_SERVER == 999:
			JOINED_SERVER = server_idx+100
			var node = get_node_or_null("Main/chat_box/RichTextLabel")
			node.bbcode_text += '[color=green]'
			node.bbcode_text += "[SYSTEM]: "
			node.bbcode_text += 'You joined the game.'
			node.bbcode_text += '[/color]'
			node.bbcode_text += '\n'
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

			if delta > 0.1000/0.30:
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
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).global_transform.origin.x)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).global_transform.origin.y)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).global_transform.origin.z)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).velocity.x)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).velocity.y)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).velocity.z)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).pivot.rotation.x)
					test.put_float(get_node_or_null("Team_A/"+str(my_username.text)).rotation.y)
					_client.get_peer(1).put_packet(test.data_array)
					test.clear()
				elif get_node_or_null("Team_B/"+str(my_username.text)) and get_node_or_null("Team_B/"+str(my_username.text)).team == 2:
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).global_transform.origin.x)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).global_transform.origin.y)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).global_transform.origin.z)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).velocity.x)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).velocity.y)
					test.put_float(get_node_or_null("Team_B/"+str(my_username.text)).velocity.z)
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
					
			if spectator_username!="" and get_node_or_null("Team_A/"+str(spectator_username)):
				$smooth_camera.target = get_node_or_null("Team_A/"+str(spectator_username)).get_node_or_null("camera_root").get_node_or_null("Position3D")
			elif spectator_username!="" and get_node_or_null("Team_B/"+str(spectator_username)):
				$smooth_camera.target = get_node_or_null("Team_B/"+str(spectator_username)).get_node_or_null("camera_root").get_node_or_null("Position3D")




func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if JOINED_SERVER != 999:
			test.put_u8(JOINED_SERVER)#code is now server_id
			test.put_u8(6)#action
			test.put_string(my_username.text)
			_client.get_peer(1).put_packet(test.data_array)
			test.clear()
		set_process(false)


func _on_submit_pressed():
		if my_username.text.length() < 1:
			$Main/start_menu/VBoxContainer/error_message.text = "username can not be empty"
		elif my_username.text.length() < 4:
			$Main/start_menu/VBoxContainer/error_message.text = "username must be longer than 3 characters long"
		if not my_username.text == "" and my_username.text.length() > 3 and my_username.text.length() < 24:
			$Main/start_menu.visible = false
			_client = WebSocketClient.new()
			 # Connect base signals to get notified of connection open, close, and errors.
			_client.connect("connection_closed", self, "_closed")
			_client.connect("connection_error", self, "_closed")
			_client.connect("connection_established", self, "_connected")
			_client.connect("data_received", self, "_on_data")
#			_client.trusted_ssl_certificate = ssl
			var err = _client.connect_to_url(websocket_url)
			if err != OK:
				$Main/start_menu.visible = false
				print("Unable to connect")
				_client = null
				set_process(false)

	
func _on_exit_pressed():
	_client.disconnect_from_host()
	$Main/server_menu.show()

func _on_join_pressed():
	test = StreamPeerBuffer.new()
	test.put_u8(2)
	test.put_u8(server_idx)
	test.put_string(my_username.text.strip_edges())
	_client.get_peer(1).put_packet(test.data_array)
	test.clear()



func _on_username_focus_entered():
	$Main/start_menu/VBoxContainer/error_message.text = ""


func server_selected(first,this):
	var id = this.get_selected_items()[0]+1
	server_idx = id
	NAMES = {}
	$Main/server_menu/VBoxContainer2/HBoxContainer2/VBoxContainer2/join.disabled = false
	test = StreamPeerBuffer.new()
	test.put_u8(1)
	test.put_u8(server_idx)
	_client.get_peer(1).put_packet(test.data_array)
	test.clear()


func mute_player_select(player,second):
	var name = second.get_item_text(second.get_selected_items()[0])
	var splited = name.rsplit(" ", true, 1)
	if splited[0] in NAMES:
		if not NAMES[splited[0]]:
			NAMES[splited[0]] = true
		else:
			NAMES[splited[0]] = false
	$Main/muted_players_menu/VBoxContainer/HBoxContainer3/ScrollContainer/ItemList.clear()
	for i in NAMES:
		if i != my_username.text:
			$Main/muted_players_menu/VBoxContainer/HBoxContainer3/ScrollContainer/ItemList.add_item(str(i)+" "+str(NAMES[i]))
	second.release_focus()
	

func _on_reset_pressed():
		reset_data_to_save = default_data_to_save
		$Main/game_settings/VBoxContainer/VBoxContainer4/HBoxContainer/HSlider.value = default_data_to_save["mouse_sensitivity"]
	
func _on_open_settings_pressed():
	$Main/in_game_menu.hide()
	$Main/game_settings.show()
	
func _on_return_pressed():
	reset_data_to_save = null
	$Main/game_settings.hide()
	if JOINED_SERVER != 999:
		$Main/in_game_menu.show()
	else:
		$Main/start_menu.show()
		$Main/server_menu.hide()


func _on_save_pressed():
	var file = File.new()
	file.open("user://saved_settings.json",File.WRITE)
	if reset_data_to_save != null:
		file.store_var(reset_data_to_save)
	else:
		file.store_var(data_to_save)
	file.close()
	reset_data_to_save = null
	print("saved ",data_to_save)
	if $Team_A.get_child_count() > 0:
		if get_node_or_null("Team_A/"+str(my_username.text)):
			get_node_or_null("Team_A/"+str(my_username.text)).reload_keys()
	elif $Team_B.get_child_count() > 0:
		if get_node_or_null("Team_B/"+str(my_username.text)):
			get_node_or_null("Team_B/"+str(my_username.text)).reload_keys()


func _on_open_muted_players_menu_pressed():
	$Main/muted_players_menu.show()
	$Main/in_game_menu.hide()
	$Main/muted_players_menu/VBoxContainer/ScrollContainer/ItemList.clear()
	if not $Main/muted_players_menu/VBoxContainer/ScrollContainer/ItemList.is_connected("item_selected",self,"mute_player_select"):
		$Main/muted_players_menu/VBoxContainer/ScrollContainer/ItemList.connect("item_selected",self,"mute_player_select",[$Main/muted_players_menu/VBoxContainer/ScrollContainer/ItemList])
	for i in NAMES:
		if i != my_username.text:
			$Main/muted_players_menu/VBoxContainer/ScrollContainer/ItemList.add_item(str(i)+" "+str(NAMES[i]))


func _on_return_to_in_game_menu_pressed():
	$Main/muted_players_menu.hide()
	$Main/in_game_menu.show()

func _on_quit_pressed():
	if my_username.text !="":
		test.put_u8(JOINED_SERVER)#code is now server_id
		test.put_string(my_username.text)
		test.put_u8(6)#action
		_client.get_peer(1).put_packet(test.data_array)
		test.clear()
		if get_node_or_null("Team_A/"+str(my_username.text)):
			$Team_A.remove_child(get_node_or_null("Team_A/"+str(my_username.text)))
		elif get_node_or_null("Team_B/"+str(my_username.text)):
			$Team_B.remove_child(get_node_or_null("Team_B/"+str(my_username.text)))
		JOINED_SERVER = 999
		$Main/in_game_menu.hide()
		get_node_or_null("Main/chat_box/RichTextLabel").bbcode_text = ""
		_on_exit_pressed()



func _on_join_match_pressed():
		if JOINED_SERVER != 999:
			$Main/in_game_join_match.hide()
			if  not get_node_or_null("Team_A/"+str(my_username.text)) and not get_node_or_null("Team_B/"+str(my_username.text)):
				$Main/in_game_choose_team.show()
			else:
				$Main/in_game_time.show()


func _on_join_spectate_pressed():
	if JOINED_SERVER != 999 and team == 0:
			for name in NAMES:
				if name != my_username.text:
					spectator_username = str(name)
					$Main/in_game_join_match.hide()
					team = 0
					break
			if spectator_username == "":
				print("no user to spectate")

func _on_spectate_pressed():
		if spectator_username == "":
			print("no user to spectate")
		else:
			if get_node_or_null("Team_A/"+str(my_username.text)):
					team = 0
					get_node_or_null("Team_A/"+str(my_username.text)).health = 0
					get_node_or_null("Team_A/"+str(my_username.text)).team = 0
					$Spectators.add_child(get_node_or_null("Team_A/"+str(my_username.text)))
					$Team_A.remove_child(get_node_or_null("Team_A/"+str(my_username.text)))
			elif get_node_or_null("Team_B/"+str(my_username.text)):
					team = 0
					get_node_or_null("Team_B/"+str(my_username.text)).health = 0
					get_node_or_null("Team_B/"+str(my_username.text)).team = 0
					$Spectators.add_child(get_node_or_null("Team_B/"+str(my_username.text)))
					$Team_B.remove_child(get_node_or_null("Team_B/"+str(my_username.text)))
			$Main/in_game_menu.hide()
			$Main/chat_box.hide()
			$Main/in_game_join_match.show()


func _on_team_a_pressed():
	if $Team_A.get_child_count() <= $Team_B.get_child_count():
		team = 1
		$Main/in_game_choose_team.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_team_b_pressed():
	if $Team_B.get_child_count() <= $Team_A.get_child_count():
		team = 2
		$Main/in_game_choose_team.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_join_other_team_pressed():
	if  get_node_or_null("Team_A/"+str(my_username.text)) and $Team_A.get_child_count() <= $Team_B.get_child_count():
		team = 2
		$Team_A.remove_child(get_node_or_null("Team_A/"+str(my_username.text)))
		$Main/in_game_menu.hide()
		$Main/in_game_choose_team.show()
	elif  get_node_or_null("Team_B/"+str(my_username.text)) and $Team_B.get_child_count() <= $Team_A.get_child_count():
		team = 1
		$Team_B.remove_child(get_node_or_null("Team_B/"+str(my_username.text)))
		$Main/in_game_menu.hide()
		$Main/in_game_choose_team.show()
	else:
		$Main/in_game_menu.hide()
		$Main/in_game_choose_team.show()
