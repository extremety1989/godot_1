extends KinematicBody

var afk_counter = 7000
var buffer = []

var position = Transform()
var health = 100
var score_a = 0
var score_b = 0
var team = 0
var deaths = 0
var kills = 0
var game_mode = 0
var game_round = 0
var muzzle = Vector3()

func _ready():
	health = 100
	set_process(true)
	afk_counter = OS.get_system_time_msecs()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <=0:
		queue_free()
	if afk_counter + 7000 < OS.get_system_time_msecs():
		var node = get_parent().get_parent().get_node("Main/chat_box/RichTextLabel")
		node.bbcode_text += '[color=red]'
		node.bbcode_text += "[SYSTEM]: "
		node.bbcode_text += str(self.name) + " just disconnected."
		node.bbcode_text += '[/color]'
		node.bbcode_text += '\n'
		queue_free()

		
func _physics_process(delta):
	global_transform.origin = lerp(global_transform.origin, position, 20 * delta)
	
func fire():
	print("firing")

