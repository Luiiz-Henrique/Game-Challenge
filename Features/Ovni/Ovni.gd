class_name Ovni
extends Node2D

## Feature do Ovni: sobrevoa o topo e desliza até a pista onde vai soltar
## o projétil. Não possui autonomia: o GameContext chama atualizar() a cada
## frame (call down). Ao chegar alinhado à pista escolhida emite
## disparar(pista_x) (signal up); o orquestrador instancia o projétil.

signal disparar(pista_x: float)

@export var intervalo_tiro: float = 1.0
@export var velocidade_movimento: float = 500.0

var _pista_alvo_x: float = 0.0
var _tempo_restante_tiro: float = 0.0


func _ready() -> void:
	_pista_alvo_x = float(GameState.PISTAS_X.pick_random())
	_tempo_restante_tiro = intervalo_tiro


## Método público orquestrado pelo GameContext (call down).
func atualizar(delta: float) -> void:
	_mover_para_pista(delta)
	_atualizar_disparo(delta)


func _mover_para_pista(delta: float) -> void:
	position.x = move_toward(position.x, _pista_alvo_x, velocidade_movimento * delta)


func _atualizar_disparo(delta: float) -> void:
	_tempo_restante_tiro -= delta
	if _tempo_restante_tiro <= 0.0 and absf(position.x - _pista_alvo_x) < 0.5:
		_tempo_restante_tiro = intervalo_tiro
		disparar.emit(_pista_alvo_x)
		_pista_alvo_x = float(GameState.PISTAS_X.pick_random())
