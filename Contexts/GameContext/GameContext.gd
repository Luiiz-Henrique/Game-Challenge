extends Node2D

## Contexto orquestrador do gameplay.
## Detém a referência do CenarioSpawner e injeta a velocidade do GameState
## a cada frame (call down). A feature em si não possui autonomia de movimento
## nem conhece o estado de pausa do jogo.

@onready var cenario_spawner: CenarioSpawner = $CenarioSpawner
@onready var barra_progressao: Control = $HUD/BarraProgressaoMap
@onready var ovni: ProjetilOvni = $Ovni

func _ready() -> void:
	# O GameContext conecta o sinal emitido pela Feature de Barra de Progressão
	barra_progressao.stage_time_finished.connect(_on_stage_time_finished)

func _on_stage_time_finished() -> void:
	_finalizar_partida()

func _finalizar_partida() -> void:
	print("[GameContext] O tempo da fase acabou!")
	
	# 1. Notifica sistemas do Core (ex: GameManager, SaveSystem, etc.)
	# CoreManager.on_game_over(reason: "time_out")
	
	# 2. Executa fluxo de encerramento do contexto (ex: pausar jogo ou chamar tela de resultados)
	get_tree().paused = true

func _process(delta: float) -> void:
	GameState.velocidade_atual = move_toward(GameState.velocidade_atual, 999999.0, 3 * delta)
	print (GameState.velocidade_atual)
	cenario_spawner.mover_cenario(delta, GameState.velocidade_atual)
	ovni.disparos_por_segundo(delta, GameState.velocidade_atual)
