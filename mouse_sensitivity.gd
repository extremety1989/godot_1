extends HSlider


onready var spin_box = get_parent().get_node("SpinBox")
onready var root = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()

func set_value(val: float) -> void:
	self.value = val
	if root and root.data_to_save:
		root.data_to_save["mouse_sensitivity"] = val

func _ready() -> void:
	self.value = 0.01
	self.min_value = 0.01
	self.max_value = 0.4
	self.step = 0.01
	self.share(spin_box)
	spin_box.min_value = min_value
	spin_box.max_value = max_value
	spin_box.step = step


func _on_HSlider_value_changed(value):
	set_value(value)
