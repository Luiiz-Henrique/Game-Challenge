extends Node2D

## Contexto orquestrador do gameplay.
## Detém as referências das features e injeta a velocidade do GameState
## a cada frame (call down). As features não possuem autonomia de movimento
## nem conhecem o estado de pausa do jogo.

@onready var cenario_spawner: CenarioSpawner = $CenarioSpawner
@onready var pedra: Pedra = $Pedra
@onready var player: Player = $Player


func _ready() -> void:
	pedra.player_atingido.connect(_on_pedra_player_atingido)


func _process(delta: float) -> void:
	var velocidade_atual := GameState.velocidade_atual
	cenario_spawner.mover_cenario(delta, velocidade_atual)
	pedra.mover(delta, velocidade_atual)
	player.atualizar(delta)


func _on_pedra_player_atingido() -> void:
	get_tree().reload_current_scene()
