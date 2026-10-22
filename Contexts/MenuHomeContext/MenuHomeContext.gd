extends TextureRect

## Contexto do menu inicial.
## Orquestra os botões do menu (call down). Os botões apenas emitem
## seus sinais nativos (signal up); este contexto decide a navegação.

const CENA_JOGO := "res://Core/Root.tscn"
@onready var botao_jogar: TextureButton = $Botao_jogar


func _ready() -> void:
	botao_jogar.pressed.connect(_on_botao_jogar_pressed)


func _on_botao_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://Contexts/MapaContext/MapaContext.tscn")
