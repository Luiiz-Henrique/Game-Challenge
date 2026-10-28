extends Control

## Contexto do storytelling inicial (Ovni -> Xicó -> Mapa).
## Orquestra as telas e as transições (call down). As telas só avisam
## quando as falas acabaram (signal up).

const CENA_MAPA := "res://Contexts/MapaContext/MapaContext.tscn"

# [CorrecaoFalas] As falas ficam no código: o editor/export perdia o valor salvo nas cenas.
const FALAS_OVNI := ["Tenho visitado o\nplaneta Terra a\ncada década e\nnessa última\nviagem descobri\num talento\npromissor nessa\nregião!", "O mecânico Xicó me\nsurpreendeu com\nsuas noções de\nEngenharia reversa.", "Preciso dele para\nampliar minha\ncaptura de fósseis\ne logo após,\ndominar essa nação!"]  # [CorrecaoFalas]
const FALAS_XICO := ["Detectei a\npresença de\ninvasores\nalienígenas\naqui, eles já\ncostumam\nbuscar rochas\ncom fósseis\nmilenares...", "De forma\nestratégica,\ndividi três\npartes de uma\narma de alta\nfrequência que\nos levará para\nlonge...", "Ao percorrer\nos diferentes\ntipos de\nambiente, eles\ndesperdiçarão\nsuas energias\ne o confronto\nfinal será\npossível!", "Bem, vejamos o\nmapa..."]  # [CorrecaoFalas]

@onready var tela_ovni: TelaFala = $TelaOvni
@onready var tela_xico: TelaFala = $TelaXico

var _transicao: TransicaoTela


func _ready() -> void:
	tela_ovni.falas_concluidas.connect(_on_tela_ovni_concluida)
	tela_xico.falas_concluidas.connect(_on_tela_xico_concluida)
	tela_ovni.falas = PackedStringArray(FALAS_OVNI)  # [CorrecaoFalas]
	tela_xico.falas = PackedStringArray(FALAS_XICO)  # [CorrecaoFalas]

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
