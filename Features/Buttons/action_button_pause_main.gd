extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_pressioned_button) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _pressioned_button() -> void:
	get_tree().paused = true	
