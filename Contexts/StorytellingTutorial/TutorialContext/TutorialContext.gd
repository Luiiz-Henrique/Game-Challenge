extends Control

## Contexto do storytelling inicial (Ovni -> Xicó -> Mapa).
## Orquestra as telas e as transições (call down). As telas só avisam
## quando as falas acabaram (signal up).

const CENA_MAPA := "res://Contexts/MapaContext/MapaContext.tscn"

@onready var tela_ovni: TelaFala = $TelaOvni
@onready var tela_xico: TelaFala = $TelaXico

var _transicao: TransicaoTela


func _ready() -> void:
	tela_ovni.falas_concluidas.connect(_on_tela_ovni_concluida)
	tela_xico.falas_concluidas.connect(_on_tela_xico_concluida)

	tela_ovni.visible = true
	tela_xico.visible = false

	_transicao = TransicaoTela.new()
	add_child(_transicao)
	_transicao.cobrir()
	await _transicao.clarear()
	tela_ovni.iniciar()


func _on_tela_ovni_concluida() -> void:
	await _transicao.escurecer()
	tela_ovni.visible = false
	tela_xico.visible = true
	await _transicao.clarear()
	tela_xico.iniciar()


func _on_tela_xico_concluida() -> void:
	TutorialProgresso.marcar_visto()
	TransicaoTela.trocar_cena(get_tree(), CENA_MAPA)
