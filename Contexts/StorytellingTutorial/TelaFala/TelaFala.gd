class_name TelaFala
extends Control

## Tela de storytelling: um background, um balão e uma lista de falas.
## Orquestra o balão e os botões (call down) e avisa o TutorialContext
## quando as falas acabam (signal up).
## Se existir o nó BotaoMapa, ele substitui o botão de próxima fala na
## última fala e é ele quem encerra a tela.

signal falas_concluidas

@export_multiline var falas: PackedStringArray = []

@onready var balao: BalaoFala = $BalaoFala
@onready var botao_proxima: TextureButton = $BotaoProximaFala
@onready var botao_mapa: TextureButton = get_node_or_null("BotaoMapa")

var _indice: int = -1

func _ready() -> void:
	botao_proxima.pressed.connect(_on_botao_proxima_pressed)
	balao.escrita_concluida.connect(_on_escrita_concluida)
	if botao_mapa != null:
		botao_mapa.visible = false
		botao_mapa.pressed.connect(_on_botao_mapa_pressed)

func iniciar() -> void:
	if falas.is_empty():
		push_warning("[TelaFala] %s não tem falas. Confira o export 'falas' no Inspetor." % name)
	_indice = -1
	botao_proxima.visible = true
	botao_proxima.disabled = false
	_mostrar_proxima_fala()

func _mostrar_proxima_fala() -> void:
	_indice += 1
	if _indice >= falas.size():
		botao_proxima.disabled = true
		falas_concluidas.emit()
		return
	if botao_mapa != null and _eh_ultima_fala():
		botao_proxima.visible = false
	balao.escrever(falas[_indice])

func _eh_ultima_fala() -> bool:
	return _indice == falas.size() - 1

## 1º toque completa o texto, 2º toque avança.
func _on_botao_proxima_pressed() -> void:
	if balao.esta_escrevendo():
		balao.completar()
	else:
		_mostrar_proxima_fala()

func _on_escrita_concluida() -> void:
	if botao_mapa != null and _eh_ultima_fala():
		botao_mapa.visible = true

func _on_botao_mapa_pressed() -> void:
	botao_mapa.disabled = true
	falas_concluidas.emit()
