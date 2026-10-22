extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(fase1) # Replace with function body.
		
func fase1() -> void:
	get_tree().change_scene_to_file("res://Core/Root.tscn")
