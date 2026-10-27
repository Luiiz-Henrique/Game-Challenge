class_name Player
extends CharacterBody2D

## Feature do jogador: seleção de pista por swipe/teclado e animação de corrida.
## Não possui autonomia de movimento horizontal: a interpolação entre pistas é
## feita em atualizar(), chamada pelo GameContext (call down). O jogador não
## acessa nós superiores; apenas emite mudou_pista (signal up).

signal mudou_pista(pista: int)

@export var largura_pista: float = 90.0
@export var posicao_centro_x: float = 201.0
@export var limite_swipe: float = 30.0
@export var suavidade: float = 15.0

const PISTA_MIN: int = -1
const PISTA_MAX: int = 1

var pista_atual: int = 0
var _posicao_inicial_toque: Vector2
var _tocando: bool = false

# Quando verdadeiro, desativa input manual e a interpolação de pista em
# atualizar(), permitindo que o FinalLevel assuma o controle via Tween.
var _controles_bloqueados: bool = false

@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	animacao.play("correr")


func _input(event: InputEvent) -> void:
	if _controles_bloqueados:
		return
	if event.is_action_pressed("ui_left"):
		mover_esquerda()
	elif event.is_action_pressed("ui_right"):
		mover_direita()
	elif event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			_posicao_inicial_toque = event.position
			_tocando = true
		elif _tocando:
			_tocando = false
			var deslize: float = event.position.x - _posicao_inicial_toque.x
			if abs(deslize) > limite_swipe:
				if deslize > 0.0:
					mover_direita()
				else:
					mover_esquerda()

## Método público orquestrado pelo GameContext (call down).
func atualizar(delta: float) -> void:
	if _controles_bloqueados:
		return
	var alvo_x: float = posicao_centro_x + (pista_atual * largura_pista)
	position.x = lerp(position.x, alvo_x, suavidade * delta)


func mover_esquerda() -> void:
	if pista_atual > PISTA_MIN:
		pista_atual -= 1
		mudou_pista.emit(pista_atual)


func mover_direita() -> void:
	if pista_atual < PISTA_MAX:
		pista_atual += 1
		mudou_pista.emit(pista_atual)


## Bloqueia ou desbloqueia os controles manuais do jogador.
## Quando bloqueado, _input e atualizar() são ignorados, permitindo que um
## orquestrador externo (ex: FinalLevel) assuma o controle da posição via Tween.
func bloquear_controles(bloqueado: bool) -> void:
	_controles_bloqueados = bloqueado
