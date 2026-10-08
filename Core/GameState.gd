extends Node

## Estado global do jogo (autoload).
## Fonte única de verdade dos dados de corrida. O GameContext lê a
## velocidade daqui e a injeta na feature CenarioSpawner (call down).

signal velocidade_alterada(nova_velocidade: float)

var velocidade_atual: float = 300.0:
	set(valor):
		velocidade_atual = valor
		velocidade_alterada.emit(velocidade_atual)
