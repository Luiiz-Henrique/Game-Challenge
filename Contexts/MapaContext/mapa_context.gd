extends TextureRect

## Contexto do mapa de fases.
## Orquestra os botões das cidades (call down): libera só as fases que o
## jogador já alcançou (ProgressoFases) e tira a nuvem de cima delas. Os
## botões apenas emitem seus sinais nativos (signal up); este contexto
## decide para qual fase navegar.

## Cena de cada fase, na ordem do mapa: índice 0 = fase 1.
const CENAS_FASES: Array[String] = [
	"res://Contexts/GameContext/Fase1.tscn",
	"res://Contexts/GameContext/Fase2.tscn",
	"res://Contexts/GameContext/Fase3.tscn",
	"res://Contexts/GameContext/Fase4.tscn",
]

## Fase 1 Galinha Choca, fase 2 Ponte Metálica, fase 3 Padre Cícero, fase 4 Sobral.
@onready var botoes_fases: Array[TextureButton] = [$GalinhaChoca, $ButtonPrimeiraCidade, $PadreCicero2, $Sobral]

## Nuvem que cobre cada fase enquanto ela está bloqueada (a fase 1 não tem).
@onready var nuvens_fases: Array[Control] = [null, $Nuvens, $Nuvens2, $Nuvens3]


func _ready() -> void:
	for indice in botoes_fases.size():
		var numero_fase := indice + 1
		var liberada := ProgressoFases.esta_desbloqueada(numero_fase)
		var botao := botoes_fases[indice]
		botao.disabled = not liberada
		if nuvens_fases[indice]:
			nuvens_fases[indice].visible = not liberada
		botao.pressed.connect(_on_botao_fase_pressed.bind(numero_fase))


func _on_botao_fase_pressed(numero_fase: int) -> void:
	# Evita toque duplo enquanto a transição acontece.
	for botao in botoes_fases:
		botao.disabled = true
	TransicaoTela.trocar_cena(get_tree(), CENAS_FASES[numero_fase - 1])
