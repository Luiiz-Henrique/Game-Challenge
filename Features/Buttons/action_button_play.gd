extends TextureButton


func _ready() -> void:
	pressed.connect(_ao_pressionar)


func _ao_pressionar() -> void:
	print("O botão Jogar foi pressionado!")
