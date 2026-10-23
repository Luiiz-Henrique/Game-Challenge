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

signal velocidade_alterada(nova_velocidade: float)

var velocidade_atual: float = VELOCIDADE_INICIAL:
	set(valor):
		velocidade_atual = valor
		velocidade_alterada.emit(velocidade_atual)

## Zera o estado de corrida. O GameContext chama no _ready(): sem isso o
## autoload carrega a velocidade da tentativa anterior para a próxima.
func reiniciar_corrida() -> void:
	velocidade_atual = VELOCIDADE_INICIAL
