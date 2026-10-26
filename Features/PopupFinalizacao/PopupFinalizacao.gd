class_name PopupFinalizacao
extends CanvasLayer

## Popup de vitória exibido ao final da fase.
## Recebe o caminho da próxima cena (proxima_cena_path) e redireciona
## o jogador para ela quando o botão de avançar é pressionado.

signal avancar(proxima_cena: String)

## Caminho da cena a ser carregada ao clicar no botão avançar.
@export var proxima_cena_path: String = ""

#@onready var container: Control = $Container
#@onready var label_titulo: Label = $Container/LabelTitulo
@onready var button_avancar: TextureButton = $ButtonProx


func _ready() -> void:
	button_avancar.pressed.connect(_on_botao_avancar_pressed)


## Configura o caminho da próxima cena a ser carregada ao avançar.
## Pode ser chamado antes de exibir o popup ou via propriedade @export.
func configurar(proxima_cena: String) -> void:
	proxima_cena_path = proxima_cena


func _on_botao_avancar_pressed() -> void:
	if proxima_cena_path.is_empty():
		push_error("[PopupFinalizacao] proxima_cena_path não foi definido.")
		return
	avancar.emit(proxima_cena_path)
	get_tree().change_scene_to_file(proxima_cena_path)
