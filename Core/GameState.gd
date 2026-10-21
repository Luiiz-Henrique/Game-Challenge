extends Node

## Estado global do jogo (autoload).
## Fonte única de verdade dos dados de corrida. O GameContext lê a
## velocidade daqui e a injeta nas features (call down).

## Posições X (centro) das três pistas. Fonte única compartilhada por
## todas as features que posicionam objetos sobre as pistas (Pedra, Ovni).
const PISTAS_X: Array[float] = [111.0, 201.0, 291.0]

signal velocidade_alterada(nova_velocidade: float)

var velocidade_atual: float = 200.0:
	set(valor):
		velocidade_atual = valor
		velocidade_alterada.emit(velocidade_atual)
		
