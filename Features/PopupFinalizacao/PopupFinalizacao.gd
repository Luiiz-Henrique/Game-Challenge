class_name PopupFinalizacao
extends CanvasLayer

## Popup de vitória exibido ao final da fase.
## Recebe o caminho da próxima cena (proxima_cena_path) e redireciona
## o jogador para ela quando o botão de avançar é pressionado. Também recebe
## o número da fase concluída para exibir a arte correspondente.

signal avancar(proxima_cena: String)

## Caminho da cena a ser carregada ao clicar no botão avançar.
@export var proxima_cena_path: String = ""

## Fase concluída (1 = primeira). Define qual arte de texturas_fase aparece.
@export var numero_fase: int = 1

## Arte "fase concluída" de cada fase, na ordem: índice 0 = fase 1.
@export var texturas_fase: Array[Texture2D] = []

#@onready var container: Control = $Container
#@onready var label_titulo: Label = $Container/LabelTitulo
@onready var fundo: TextureRect = $TextureRect
@onready var button_avancar: TextureButton = $ButtonProx


func _ready() -> void:
	button_avancar.pressed.connect(_on_botao_avancar_pressed)
	_aplicar_textura_fase()


## Configura o caminho da próxima cena e a fase concluída.
## Deve ser chamado antes de adicionar o popup à árvore.
func configurar(proxima_cena: String, fase: int) -> void:
	proxima_cena_path = proxima_cena
	numero_fase = fase


func _aplicar_textura_fase() -> void:
	var indice := numero_fase - 1
	if indice < 0 or indice >= texturas_fase.size() or texturas_fase[indice] == null:
		push_warning("[PopupFinalizacao] Sem arte para a fase %d; mantendo a padrão." % numero_fase)
		return
	fundo.texture = texturas_fase[indice]


func _on_botao_avancar_pressed() -> void:
	if proxima_cena_path.is_empty():
		push_error("[PopupFinalizacao] proxima_cena_path não foi definido.")
		return
	avancar.emit(proxima_cena_path)
	get_tree().change_scene_to_file(proxima_cena_path)
