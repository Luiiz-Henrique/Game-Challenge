class_name DiretorPadroes
extends Node

## Feature que decide o que vem pela pista: obstáculos e tiros do Ovni.
## Em vez de sortear objetos soltos, sorteia padrões (Simples, Tiro, Combo,
## Dupla...) dentro das ondas de pressão e calma do PhaseConfig. Não cria
## nada: apenas emite pedidos (signal up) e o GameContext instancia os
## obstáculos e dá as ordens ao Ovni (call down).
##
## Regras de justiça, garantidas para todo padrão:
##   1. Sempre sobra pelo menos uma pista livre quando o padrão chega.
##   2. Numa dupla, o tiro só vai numa pista já bloqueada.
##   3. Entre dois padrões há tempo de o jogador sair da pista livre de um
##      e chegar na pista livre do outro (atravessar 2 pistas leva mais).

signal criar_obstaculo(pista: int)
signal agendar_tiro(pista: int, atraso: float)

## Bits de OndaConfig.padroes (mesma ordem do @export_flags).
const SIMPLES := 1
const TIRO := 2
const COMBO := 4
const DUPLA := 8
const DUPLA_TIRO := 16


## Um padrão sorteado: o que aparece em cada pista e quando chega ao jogador.
class Padrao:
	var obstaculos: Array[int] = []
	var tiro: int = -1
	var seguras: Array[int] = []
	var chegada: float = 0.0


var _config: PhaseConfig
var _ativo: bool = false
var _tempo: float = 0.0

## Distâncias (px) até a linha do jogador: do ponto onde o obstáculo
## surge e da altura de onde o Ovni atira.
var _distancia_obstaculo: float = 0.0
var _distancia_tiro: float = 0.0

## Próximo padrão já sorteado, esperando a hora de ser lançado.
var _proximo: Padrao = null
## Pistas livres do último padrão lançado e quando ele chega ao jogador.
var _seguras_anteriores: Array[int] = [0, 1, 2]
var _chegada_anterior: float = 1.0
## Instante em que o Ovni dispara o último tiro agendado.
var _ovni_livre_em: float = 0.0


## Prepara o diretor para a fase (call down do GameContext). Sem ondas no
## config o diretor fica inativo e a fase usa o comportamento antigo.
func configurar(config: PhaseConfig, y_player: float, y_ovni: float, y_surgimento: float) -> void:
	_config = config
	_distancia_obstaculo = y_player - y_surgimento
	_distancia_tiro = y_player - y_ovni
	_ativo = config != null and not config.ondas.is_empty()


func esta_ativo() -> bool:
	return _ativo


## Para de lançar padrões (fim da fase).
func parar() -> void:
	_ativo = false
	_proximo = null


## Método público orquestrado pelo GameContext a cada frame (call down).
func atualizar(delta: float) -> void:
	if not _ativo:
		return
	_tempo += delta
	if _proximo == null:
		_proximo = _sortear_padrao()
		if _proximo == null:
			return
	if _tempo >= _proximo.chegada - _antecedencia(_proximo):
		_lancar(_proximo)
		_proximo = null


func _lancar(padrao: Padrao) -> void:
	for pista in padrao.obstaculos:
		criar_obstaculo.emit(pista)
	if padrao.tiro >= 0:
		# O tiro sai a tempo de chegar junto com o padrão; se não der para o
		# Ovni se preparar, sai um pouco atrasado (nunca adiantado).
		var atraso: float = maxf(padrao.chegada - _tempo - _tempo_tiro(), _config.aviso_tiro + 0.1)
		agendar_tiro.emit(padrao.tiro, atraso)
		_ovni_livre_em = _tempo + atraso
	_seguras_anteriores = padrao.seguras
	_chegada_anterior = padrao.chegada


func _sortear_padrao() -> Padrao:
	var local: Dictionary = _localizar(_chegada_anterior)
	if local.is_empty():
		return null
	var onda: OndaConfig = local.onda
	var base: float = _chegada_anterior + onda.intervalo_padroes

	# Nada chega ao jogador durante a calma: o padrão vai para depois dela.
	local = _localizar(base)
	if local.is_empty():
		return null
	if local.fim_calma >= 0.0:
		base = local.fim_calma
		local = _localizar(base)
		if local.is_empty():
			return null
	onda = local.onda

	var tipos: Array[int] = []
	for bit in [SIMPLES, TIRO, COMBO, DUPLA, DUPLA_TIRO]:
		if onda.padroes & bit:
			tipos.append(bit)
	if tipos.is_empty():
		return null

	var padrao := _montar(tipos.pick_random())
	padrao.chegada = maxf(base, _chegada_anterior + _intervalo_minimo(_seguras_anteriores, padrao.seguras))
	# Obstáculos precisam de tempo para descer da borda da tela.
	padrao.chegada = maxf(padrao.chegada, _tempo + _antecedencia(padrao))
	# O Ovni atira um tiro de cada vez e precisa se preparar entre eles.
	if padrao.tiro >= 0:
		padrao.chegada = maxf(padrao.chegada, _ovni_livre_em + _preparo_ovni() + _tempo_tiro())
	return padrao


## Monta as pistas do padrão (0, 1 e 2 = esquerda, meio e direita).
func _montar(tipo: int) -> Padrao:
	var padrao := Padrao.new()
	var pistas: Array[int] = [0, 1, 2]
	pistas.shuffle()
	match tipo:
		SIMPLES:
			padrao.obstaculos.assign([pistas[0]])
			padrao.seguras.assign([pistas[1], pistas[2]])
		TIRO:
			padrao.tiro = pistas[0]
			padrao.seguras.assign([pistas[1], pistas[2]])
		COMBO:
			padrao.obstaculos.assign([pistas[0]])
			padrao.tiro = pistas[1]
			padrao.seguras.assign([pistas[2]])
		DUPLA:
			padrao.obstaculos.assign([pistas[0], pistas[1]])
			padrao.seguras.assign([pistas[2]])
		DUPLA_TIRO:
			# Regra 2: o tiro cai numa pista já bloqueada, nunca na livre.
			padrao.obstaculos.assign([pistas[0], pistas[1]])
			padrao.tiro = pistas[0]
			padrao.seguras.assign([pistas[2]])
	return padrao


## Regra 3: tempo mínimo entre dois padrões chegarem. O jogador espera o
## padrão anterior passar (ocupação), reage e anda até a nova pista livre.
## Considera o pior caso: ele pode estar em qualquer pista livre anterior.
func _intervalo_minimo(de: Array[int], para: Array[int]) -> float:
	var distancia: int = 0
	for p in de:
		var menor: int = 2
		for q in para:
			menor = mini(menor, absi(p - q))
		distancia = maxi(distancia, menor)
	var ocupacao: float = _config.altura_contato / _velocidade_cenario()
	return ocupacao + _config.tempo_reacao + _config.tempo_por_pista * distancia


## Quanto antes da chegada o padrão precisa ser lançado.
func _antecedencia(padrao: Padrao) -> float:
	if not padrao.obstaculos.is_empty():
		return _distancia_obstaculo / _velocidade_cenario()
	return _tempo_tiro() + _preparo_ovni()


## Tempo do projétil sair do Ovni e chegar ao jogador.
func _tempo_tiro() -> float:
	return _distancia_tiro / maxf(GameState.velocidade_projetil_atual(), 1.0)


## Tempo para o Ovni atravessar a tela inteira e piscar o aviso.
func _preparo_ovni() -> float:
	var travessia: float = GameState.PISTAS_X[2] - GameState.PISTAS_X[0]
	return travessia / (_velocidade_cenario() * Ovni.FATOR_VELOCIDADE) + _config.aviso_tiro


func _velocidade_cenario() -> float:
	return maxf(GameState.velocidade_atual, 1.0)


## Onda em que o instante t cai e, se t estiver numa calma, quando ela
## acaba (fim_calma = -1 quando t está na pressão). A última onda se
## repete até a fase terminar.
func _localizar(t: float) -> Dictionary:
	var ondas: Array[OndaConfig] = _config.ondas
	var inicio: float = 0.0
	var indice: int = 0
	while true:
		var onda: OndaConfig = ondas[mini(indice, ondas.size() - 1)]
		if onda == null:
			push_error("[DiretorPadroes] Onda %d vazia no PhaseConfig." % indice)
			return {}
		var fim_pressao: float = inicio + onda.duracao_pressao
		var fim_calma: float = fim_pressao + onda.duracao_calma
		if t < fim_calma or onda.duracao_pressao + onda.duracao_calma <= 0.0:
			return {"onda": onda, "fim_calma": fim_calma if t >= fim_pressao else -1.0}
		inicio = fim_calma
		indice += 1
	return {}
