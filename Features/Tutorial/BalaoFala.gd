class_name BalaoFala
extends TextureRect

## Balão de fala com texto aparecendo como máquina de escrever.
## Só escreve e avisa quando terminou (signal up); quem decide a próxima
## fala é o contexto.

signal escrita_concluida

@export var textura_balao: Texture2D:
	set(valor):
		textura_balao = valor
		texture = valor

@export_group("Texto")
@export var fonte: Font
@export var tamanho_fonte: int = 17
@export var cor_texto: Color = Color.BLACK
@export var espacamento_linhas: int = 2
@export var caracteres_por_segundo: float = 30.0

@export_group("Margens do texto")
@export var margem_esquerda: float = 20.0
@export var margem_topo: float = 20.0
@export var margem_direita: float = 20.0
@export var margem_baixo: float = 20.0

@onready var label: Label = $Texto

var _tween: Tween


func _ready() -> void:
	_aplicar_estilo()
	limpar()


func escrever(texto: String) -> void:
	_parar_tween()
	label.text = texto
	label.visible_characters = 0
	var total := label.get_total_character_count()
	_tween = create_tween()
	_tween.tween_property(label, "visible_characters", total, total / caracteres_por_segundo)
	_tween.finished.connect(_on_escrita_terminada)


## Mostra o texto inteiro na hora.
func completar() -> void:
	if not esta_escrevendo():
		return
	_parar_tween()
	_on_escrita_terminada()


func esta_escrevendo() -> bool:
	return _tween != null and _tween.is_running()


func limpar() -> void:
	_parar_tween()
	label.text = ""


func _on_escrita_terminada() -> void:
	label.visible_characters = -1
	escrita_concluida.emit()


func _parar_tween() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null


func _aplicar_estilo() -> void:
	texture = textura_balao
	label.offset_left = margem_esquerda
	label.offset_top = margem_topo
	label.offset_right = -margem_direita
	label.offset_bottom = -margem_baixo
	if fonte != null:
		label.add_theme_font_override("font", fonte)
	label.add_theme_font_size_override("font_size", tamanho_fonte)
	label.add_theme_color_override("font_color", cor_texto)
	label.add_theme_constant_override("line_spacing", espacamento_linhas)
