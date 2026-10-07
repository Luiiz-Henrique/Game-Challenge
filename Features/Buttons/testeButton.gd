extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Conecta o sinal de clique do próprio botão à nossa função de imprimir
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# A mensagem que vai aparecer no painel de Saída (Output) da Godot
	print("O botão de entrar foi apertado com sucesso!")
