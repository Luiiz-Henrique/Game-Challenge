extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(back)



func back() -> void:
	get_tree().change_scene_to_file("res://Contexts/MenuHomeContext/MenuHomeContext.tscn")
