extends Node

## Estado global do jogo (autoload).
## Fonte única de verdade dos dados de corrida. O GameContext lê a
## velocidade daqui e a injeta nas features (call down).

## Posições X (centro) das três pistas. Fonte única compartilhada por
## todas as features que posicionam objetos sobre as pistas (Pedra, Ovni).
const PISTAS_X: Array[float] = [111.0, 201.0, 291.0]

## Curva de dificuldade da fase base (px/s). São os dois números que se
## ajustam para deixar a corrida mais fácil ou mais dura.
const VELOCIDADE_INICIAL: float = 200.0
const VELOCIDADE_MAXIMA: float = 650.0

## Velocidade do projétil do Ovni (px/s). Cresce junto com a dificuldade,
## mas tem escala própria: 400 no início e 900 no máximo.
const VELOCIDADE_PROJETIL_INICIAL: float = 401.0
const VELOCIDADE_PROJETIL_MAXIMA: float = 900.0

## Tempo (s) que a velocidade leva para ir do início ao máximo dentro de uma
## corrida. Quanto menor, mais rápido a dificuldade sobe.
const TEMPO_ATE_VELOCIDADE_MAXIMA: float = 180.0

signal velocidade_alterada(nova_velocidade: float)

## Tempo decorrido da corrida atual (zerado a cada corrida pelo GameContext).
var tempo_corrida: float = 0.0

## Progresso suavizado da dificuldade (0.0 no início, 1.0 no máximo).
var progresso_dificuldade: float = 0.0

var velocidade_atual: float = VELOCIDADE_INICIAL:
	set(valor):
		velocidade_atual = valor
		velocidade_alterada.emit(velocidade_atual)

## Avança a dificuldade de forma gradual (curva suave, estilo Subway Surfers).
## O GameContext chama a cada frame enquanto a corrida não está pausada.
func avancar_dificuldade(delta: float) -> void:
	tempo_corrida += delta
	var t: float = clampf(tempo_corrida / TEMPO_ATE_VELOCIDADE_MAXIMA, 0.0, 1.0)
	progresso_dificuldade = t * t * (3.0 - 2.0 * t)
	velocidade_atual = lerpf(VELOCIDADE_INICIAL, VELOCIDADE_MAXIMA, progresso_dificuldade)


## Zera a corrida. Chamado no _ready do GameContext: como o retry recarrega a
## cena, a velocidade volta ao início sempre que o jogador bate.
func reiniciar_corrida() -> void:
	tempo_corrida = 0.0
	progresso_dificuldade = 0.0
	velocidade_atual = VELOCIDADE_INICIAL
