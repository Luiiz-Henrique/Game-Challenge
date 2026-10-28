extends Node2D

## Contexto orquestrador do gameplay.
## Detém as referências das features e injeta a velocidade do GameState
## a cada frame (call down). Também coordena os projéteis disparados pelo
## Ovni: o Ovni apenas emite disparar() (signal up) e este contexto cria,
## move e libera os projéteis num referencial fixo (o do GameContext).

const CENA_PROJETIL := preload("res://Features/Ovni/Projetil.tscn")
const VELOCIDADE_PROJETIL: float = 600.0
const CENA_MAPA := "res://Contexts/MapaContext/MapaContext.tscn"

## Número desta fase no mapa (1 a ProgressoFases.TOTAL_FASES). Cada cena de
## fase (Fase1.tscn, Fase2.tscn...) sobrescreve este valor.
@export var numero_fase: int = 1

## Duração, velocidades, obstáculo e cadência de tiro desta fase.
@export var config_fase: PhaseConfig

@onready var cenario_spawner: CenarioSpawner = $CenarioSpawner
@onready var barra_progressao: BarraProgressaoMap = $BarraProgressaoMap
@onready var pedra: Pedra = $Pedra
@onready var player: Player = $Player
@onready var ovni: Ovni = $Ovni
@onready var popup: TextureRect = $PopupColisao
@onready var button_pause: TextureRect = $Pause


var FinalLevelScript= preload("res://Features/FinalLevel/FinalLevel.gd")

func _ready() -> void:
	# Zera a dificuldade a cada corrida. Como o retry recarrega a cena,
	# a velocidade volta ao início quando o jogador bate (estilo Subway Surfers).
	GameState.reiniciar_corrida(config_fase)
	_aplicar_config_fase()
	button_pause.hide()
	popup.hide()
#	ovni.disparar.connect(_on_ovni_disparar)
	pedra.player_atingido.connect(_reiniciar_corrida)
	ovni.player_atingido.connect(_reiniciar_corrida)
	# O GameContext conecta o sinal emitido pela Feature de Barra de Progressão
	barra_progressao.stage_time_finished.connect(_on_stage_time_finished)
	AudioMenu.diminuir_volume()

func _aplicar_config_fase() -> void:
	if config_fase == null:
		return
	barra_progressao.configurar_tempo(config_fase.tempo_fase)
	ovni.configurar_disparos(config_fase.intervalo_disparo, config_fase.intervalo_minimo, config_fase.disparos_aceleram_com_dificuldade)
	if config_fase.tem_pedra:
		pedra.configurar_textura(config_fase.textura_obstaculo)
	else:
		pedra.desativar()


func _on_stage_time_finished() -> void:
	#_finalizar_partida()
	#_reiniciar_corrida()
	# Libera a próxima fase já aqui: se o jogador sair durante a animação,
	# o progresso não se perde.
	ProgressoFases.concluir(numero_fase)
	var final_level = Node.new()
	final_level.set_script(FinalLevelScript)
	add_child(final_level)
	var hud: Array[CanvasItem] = [barra_progressao, $ButtonPauseInGame]
	final_level.iniciar_finalizacao(player, ovni, CENA_MAPA, numero_fase, hud)
	

#func _finalizar_partida() -> void:
	#print("[GameContext] O tempo da fase acabou!")
	#
	## 1. Notifica sistemas do Core (ex: GameManager, SaveSystem, etc.)
	## CoreManager.on_game_over(reason: "time_out")
	#
	## 2. Executa fluxo de encerramento do contexto (ex: pausar jogo ou chamar tela de resultados)
	#get_tree().paused = true

func _process(delta: float) -> void:
	# A velocidade cresce durante a corrida; zera no _ready ao (re)iniciar.
	GameState.avancar_dificuldade(delta)
	var velocidade_atual: float = GameState.velocidade_atual
	cenario_spawner.mover_cenario(delta, velocidade_atual)
	if pedra.visible:
		pedra.mover(delta, velocidade_atual)
	player.atualizar(delta)
	#ovni.atualizar(delta)
	#_atualizar_projeteis(delta)
	ovni.disparos_por_segundo(delta)


#func _on_ovni_disparar(pista_x: float) -> void:
	#var projetil := CENA_PROJETIL.instantiate() as Projetil
	#projetil.position = Vector2(pista_x, ovni.position.y)
	#projetil.player_atingido.connect(_reiniciar_corrida)
	#projeteis.add_child(projetil)


#func _atualizar_projeteis(delta: float) -> void:
	#for no in projetil.get_children():
		#if no is Projetil:
			#no.mover(delta, VELOCIDADE_PROJETIL)
			#if no.position.y > get_viewport_rect().size.y + 100:
				#no.queue_free()

	
func _reiniciar_corrida() -> void:
	$Colisao_audio.play()
	
	popup.show()
	get_tree().paused = true



func _on_button_pause_in_game_pressed() -> void:
	$AudioBotoes.play()
	button_pause.show()
	get_tree().paused = true 
	print("Clique no botão de pausa recebido") 
