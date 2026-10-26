extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(change_phase) # Replace with function body.
		
func change_phase() -> void:
	get_tree().change_scene_to_file("res://Core/Root.tscn")
