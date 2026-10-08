extends Node2D

## Contexto orquestrador do gameplay.
## Detém a referência do CenarioSpawner e injeta a velocidade do GameState
## a cada frame (call down). A feature em si não possui autonomia de movimento
## nem conhece o estado de pausa do jogo.

@onready var cenario_spawner: CenarioSpawner = $CenarioSpawner


func _process(delta: float) -> void:
	cenario_spawner.mover_cenario(delta, GameState.velocidade_atual)
