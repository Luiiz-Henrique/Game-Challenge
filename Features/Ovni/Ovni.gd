#class_name Ovni
#extends Node2D

## Feature do Ovni: sobrevoa o topo e desliza até a pista onde vai soltar
## o projétil. Não possui autonomia: o GameContext chama atualizar() a cada
## frame (call down). Ao chegar alinhado à pista escolhida emite
## disparar(pista_x) (signal up); o orquestrador instancia o projétil.

#signal disparar(pista_x: float)
#signal player_atingido

#var projetil_ovni = preload("res://Features/Ovni/Projetil.tscn")
#var valores_spawner = [122, 205, 288]
#@export var intervalo_tiro: float = 1.0
#@export var velocidade_movimento: float = 500.0
#@onready var disparo_ovni: Timer = $Timer
#
#var _pista_alvo_x: float = 0.0
#var _tempo_restante_tiro: float = 0.0




#func disparos_por_segundo(delta: float) -> void:
	#disparo_ovni.wait_time = move_toward(disparo_ovni.wait_time, 0.5, 0.01 * delta)

#func _ready() -> void:
	#_pista_alvo_x = float(GameState.PISTAS_X.pick_random())
	#_tempo_restante_tiro = intervalo_tiro
#
#
### Método público orquestrado pelo GameContext (call down).
#func atualizar(delta: float) -> void:
	#_mover_para_pista(delta)
	#_atualizar_disparo(delta)
#
#
#func _mover_para_pista(delta: float) -> void:
	#position.x = move_toward(position.x, _pista_alvo_x, velocidade_movimento * delta)
#
#
#func _atualizar_disparo(delta: float) -> void:
	#_tempo_restante_tiro -= delta
	#if _tempo_restante_tiro <= 0.0 and absf(position.x - _pista_alvo_x) < 0.5:
		#_tempo_restante_tiro = intervalo_tiro
		#disparar.emit(_pista_alvo_x)
		#_pista_alvo_x = float(GameState.PISTAS_X.pick_random())


#func _on_atack_timer_timeout():
	# 1. Cria a instância do fogo
	#var novo_projetil = projetil_ovni.instantiate()
	
	# 2. Adiciona o fogo na cena principal (Fase_1)
	#get_tree().current_scene.add_child(novo_projetil)
	
	
	# 3. Sorteia uma das 3 pistas
	#var pista_alvo = GameState.PISTAS_X.pick_random()
	
	#novo_projetil.player_atingido.connect(func(): player_atingido.emit())
	
	# 4. Define a posição inicial do fogo:
	# O 'X' será exatamente a pista sorteada.
	# O 'Y' será exatamente a posição atual da boca do dragão.
	#novo_projetil.global_position = Vector2(pista_alvo, self.global_position.y)
	#global_position.x = pista_alvo
	
class_name Ovni
extends Node2D

@onready var disparo_ovni: Timer = $Timer
@export var tempo_deslocamento: float = 0.35 # Duração em segundos da nave mudando de pista


signal player_atingido
var projetil_ovni = preload("res://Features/Ovni/Projetil.tscn")
var tween_movimento: Tween

## A nave troca de pista a esta fração acima da velocidade do cenário.
## O DiretorPadroes usa o mesmo fator para calcular o preparo do tiro.
const FATOR_VELOCIDADE: float = 1.2

## Cor do piscar que avisa que o tiro vai sair.
const COR_AVISO := Color(1.0, 0.35, 0.35)

## Duração (s) do piscar antes de cada tiro ordenado pelo diretor.
var tempo_aviso: float = 0.3
var _tween_aviso: Tween

## Tiros ordenados pelo diretor, em ordem: x = pista, y = instante do disparo
## no relógio da nave. Executados um de cada vez.
var _ordens: Array[Vector2] = []
var _executando_ordem: bool = false
var _relogio: float = 0.0

## Intervalo entre disparos vai caindo até este piso durante a fase.
var intervalo_minimo: float = 1.5
var disparos_aceleram: bool = true


func _ready() -> void:
	# Vai para a primeira pista já no início. O primeiro disparo só acontece
	# quando o Timer completar o tempo de espera, já parado no alvo.
	_mover_para_pista(GameState.PISTAS_X.pick_random(), GameState.velocidade_atual * FATOR_VELOCIDADE)
	$Audio_nave.play()


func _process(delta: float) -> void:
	_relogio += delta



func _mover_para_pista(pista_x: float, velocidade_atual: float) -> void:
	# Calcula a distância em pixels entre a posição atual e a pista alvo
	var distancia: float = abs(pista_x - global_position.x)
	
	# Se a nave já estiver na pista sorteada, não precisa criar Tween
	if distancia < 1.0:
		return

	# Cancela animação anterior caso o Timer tenha disparado muito rápido
	if tween_movimento and tween_movimento.is_running():
		tween_movimento.kill()
		
	# Tempo (s) = Distância (px) / Velocidade (px/s)
	var duracao_movimento: float = distancia / velocidade_atual

	
	tween_movimento = create_tween()
	tween_movimento.tween_property(self, "global_position:x", pista_x, duracao_movimento)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
		

## Define a cadência de tiro da fase (call down do GameContext).
func configurar_disparos(intervalo_inicial: float, minimo: float, aceleram: bool) -> void:
	intervalo_minimo = minimo
	disparos_aceleram = aceleram
	disparo_ovni.wait_time = intervalo_inicial
	disparo_ovni.start()


func disparos_por_segundo(delta: float) -> void:
	if not disparos_aceleram:
		return
	disparo_ovni.wait_time = move_toward(disparo_ovni.wait_time, intervalo_minimo, 0.01 * delta)
	
func cessar_disparos() -> void:
	disparo_ovni.set_block_signals(true)
	_ordens.clear()
	_executando_ordem = false
	if tween_movimento and tween_movimento.is_running():
		tween_movimento.kill()
	if _tween_aviso and _tween_aviso.is_running():
		_tween_aviso.kill()
	modulate = Color.WHITE


## Passa a atirar só quando o DiretorPadroes mandar (call down do
## GameContext): desliga o Timer de tiros sorteados.
func aguardar_ordens(aviso: float) -> void:
	tempo_aviso = aviso
	disparo_ovni.stop()


## Ordem do diretor: ir até a pista, piscar e atirar daqui a `atraso` segundos.
func agendar_tiro(pista_x: float, atraso: float) -> void:
	_ordens.append(Vector2(pista_x, _relogio + atraso))
	if not _executando_ordem:
		_executar_proxima_ordem()


func _executar_proxima_ordem() -> void:
	if _ordens.is_empty():
		_executando_ordem = false
		return
	_executando_ordem = true
	var ordem: Vector2 = _ordens.pop_front()
	var atraso: float = maxf(ordem.y - _relogio, 0.0)
	var aviso: float = minf(tempo_aviso, atraso)

	# Vai até a pista o quanto antes e espera lá: a posição já é um aviso.
	var velocidade: float = maxf(GameState.velocidade_atual * FATOR_VELOCIDADE, 1.0)
	var deslocamento: float = minf(absf(ordem.x - global_position.x) / velocidade, atraso - aviso)

	if tween_movimento and tween_movimento.is_running():
		tween_movimento.kill()
	tween_movimento = create_tween()
	if deslocamento > 0.0:
		tween_movimento.tween_property(self, "global_position:x", ordem.x, deslocamento)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	else:
		global_position.x = ordem.x
	tween_movimento.tween_interval(maxf(atraso - aviso - deslocamento, 0.0))
	tween_movimento.tween_callback(_piscar.bind(aviso))
	tween_movimento.tween_interval(aviso)
	tween_movimento.tween_callback(_disparar_projetil)
	tween_movimento.tween_callback(_executar_proxima_ordem)


## Pisca duas vezes na cor de aviso durante `duracao` segundos.
func _piscar(duracao: float) -> void:
	if duracao <= 0.0:
		return
	if _tween_aviso and _tween_aviso.is_running():
		_tween_aviso.kill()
	var etapa: float = duracao / 4.0
	_tween_aviso = create_tween()
	for i in 2:
		_tween_aviso.tween_property(self, "modulate", COR_AVISO, etapa)
		_tween_aviso.tween_property(self, "modulate", Color.WHITE, etapa)

func _on_atack_timer_timeout() -> void:
	# A nave passou a espera parada na pista alvo: dispara daqui mesmo.
	_disparar_projetil()

	# Só então escolhe a próxima pista e se desloca. Assim o tempo de espera
	# até o próximo tiro acontece já no local onde ele vai atirar.
	_mover_para_pista(GameState.PISTAS_X.pick_random(), GameState.velocidade_atual * FATOR_VELOCIDADE)
	
func _disparar_projetil() -> void:
	var novo_projetil = projetil_ovni.instantiate()

	# Repassa a colisão para o GameContext.
	novo_projetil.player_atingido.connect(
		func(): player_atingido.emit()
	)

	get_tree().current_scene.add_child(novo_projetil)

	# Posiciona o projétil na nave.
	novo_projetil.global_position = global_position
	$Audio_tiros.play()
