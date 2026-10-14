extends TextureButton
#Teste para observacao 
var state: bool = false

func _ready() -> void:
	pressed.connect(_pressioned_button)
	pressed.connect(change_scene_to_file)


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _pressioned_button() -> void: 
	print("O botão de entrar foi apertado com sucesso!")
	
	
func change_scene_to_file() -> void:
	print("testando.....")
	get_tree().change_scene_to_file("res://Core/Root.tscn")
	
