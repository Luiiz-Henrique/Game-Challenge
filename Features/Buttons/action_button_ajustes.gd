extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pressed.connect(_pressioned_button)
  pressed.connect(change_scene_to_file)

	
	
	
func _pressioned_button() -> void: 
 print("O botão de rankink foi apertado com sucesso!")
	
	
	
func change_scene_to_file() -> void:
 print("testando.....")
