extends Spatial
export (NodePath) var follow_target = null

var target: Spatial
var update = false
var gt_prev: Transform
var gt_current: Transform


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	target = get_node_or_null(follow_target)
	if target == null:
		target = get_parent()
	global_transform = target.global_transform
	gt_prev = target.global_transform
	gt_current = target.global_transform

func update_transform():
	gt_prev = gt_current
	gt_current = target.global_transform

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update:
		update_transform()
		update = false
	var f = clamp(Engine.get_physics_interpolation_fraction(),0,1)
	global_transform = gt_prev.interpolate_with(gt_current,f)
	
func _physics_process(delta):
	update = true
