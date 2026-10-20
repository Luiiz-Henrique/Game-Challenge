extends Node2D

## Contexto orquestrador do gameplay.
## Detém as referências das features e injeta a velocidade do GameState
## a cada frame (call down). Também coordena os projéteis disparados pelo
## Ovni: o Ovni apenas emite disparar() (signal up) e este contexto cria,
## move e libera os projéteis num referencial fixo (o do GameContext).

const CENA_PROJETIL := preload("res://Features/Ovni/Projetil.tscn")
const VELOCIDADE_PROJETIL: float = 600.0

@onready var cenario_spawner: CenarioSpawner = $CenarioSpawner
@onready var barra_progressao: Control = $HUD/BarraProgressaoMap
@onready var ovni: ProjetilOvni = $Ovni

@onready var pedra: Pedra = $Pedra
@onready var player: Player = $Player
@onready var ovni: Ovni = $Ovni
@onready var projeteis: Node2D = $Projeteis
@onready var popup: TextureRect = $PopupColisao

func _ready() -> void:
	popup.hide()
	ovni.disparar.connect(_on_ovni_disparar)
	pedra.player_atingido.connect(_reiniciar_corrida)

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
	var velocidade_atual = move_toward(GameState.velocidade_atual, 999999.0, 3 * delta)
	cenario_spawner.mover_cenario(delta, velocidade_atual)
	pedra.mover(delta, velocidade_atual)
	player.atualizar(delta)
	ovni.atualizar(delta)
	_atualizar_projeteis(delta)
	print (velocidade_atuall)
	ovni.disparos_por_segundo(delta, velocidade_atual)


func _on_ovni_disparar(pista_x: float) -> void:
	var projetil := CENA_PROJETIL.instantiate() as Projetil
	projetil.position = Vector2(pista_x, ovni.position.y)
	projetil.atingiu_player.connect(_reiniciar_corrida)
	projeteis.add_child(projetil)


func _atualizar_projeteis(delta: float) -> void:
	for no in projeteis.get_children():
		if no is Projetil:
			no.mover(delta, VELOCIDADE_PROJETIL)
			if no.position.y > get_viewport_rect().size.y + 100:
				no.queue_free()

	
func _reiniciar_corrida() -> void:
	popup.show()
	get_tree().paused = true
