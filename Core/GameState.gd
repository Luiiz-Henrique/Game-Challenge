extends Node

## Estado global do jogo (autoload).
## Fonte única de verdade dos dados de corrida. O GameContext lê a
## velocidade daqui e a injeta nas features (call down).

## Posições X (centro) das três pistas. Fonte única compartilhada por
## todas as features que posicionam objetos sobre as pistas (Pedra, Ovni).
const PISTAS_X: Array[float] = [111.0, 201.0, 291.0]

## Curva de dificuldade padrão (px/s), usada quando a fase não traz um
## PhaseConfig. Cada fase sobrescreve esses valores em reiniciar_corrida().
const VELOCIDADE_INICIAL: float = 200.0
const VELOCIDADE_MAXIMA: float = 650.0

## Velocidade padrão do projétil do Ovni (px/s). Cresce junto com a
## dificuldade, mas tem escala própria.
const VELOCIDADE_PROJETIL_INICIAL: float = 401.0
const VELOCIDADE_PROJETIL_MAXIMA: float = 900.0


const TEMPO_ATE_VELOCIDADE_MAXIMA: float = 180.0

signal velocidade_alterada(nova_velocidade: float)

## Tempo decorrido da corrida atual (zerado a cada corrida pelo GameContext).
var tempo_corrida: float = 0.0

## Progresso suavizado da dificuldade (0.0 no início, 1.0 no máximo).
var progresso_dificuldade: float = 0.0

## Curva da fase em andamento (copiada do PhaseConfig da fase).
var velocidade_inicial: float = VELOCIDADE_INICIAL
var velocidade_maxima: float = VELOCIDADE_MAXIMA
var velocidade_projetil_inicial: float = VELOCIDADE_PROJETIL_INICIAL
var velocidade_projetil_maxima: float = VELOCIDADE_PROJETIL_MAXIMA
var tempo_ate_velocidade_maxima: float = TEMPO_ATE_VELOCIDADE_MAXIMA

var velocidade_atual: float = VELOCIDADE_INICIAL:
	set(valor):
		velocidade_atual = valor
		velocidade_alterada.emit(velocidade_atual)

## Avança a dificuldade de forma gradual (curva suave, estilo Subway Surfers).
## O GameContext chama a cada frame enquanto a corrida não está pausada.
func avancar_dificuldade(delta: float) -> void:
	tempo_corrida += delta
	var t: float = clampf(tempo_corrida / tempo_ate_velocidade_maxima, 0.0, 1.0)
	progresso_dificuldade = t * t * (3.0 - 2.0 * t)
	velocidade_atual = lerpf(velocidade_inicial, velocidade_maxima, progresso_dificuldade)


## Velocidade do projétil para o momento atual da corrida.
func velocidade_projetil_atual() -> float:
	return lerpf(velocidade_projetil_inicial, velocidade_projetil_maxima, progresso_dificuldade)


## Zera a corrida. Chamado no _ready do GameContext: como o retry recarrega a
## cena, a velocidade volta ao início sempre que o jogador bate.
## Sem config, volta à curva padrão.
func reiniciar_corrida(config: PhaseConfig = null) -> void:
	if config:
		velocidade_inicial = config.velocidade_inicial
		velocidade_maxima = config.velocidade_maxima
		velocidade_projetil_inicial = config.velocidade_projetil_inicial
		velocidade_projetil_maxima = config.velocidade_projetil_maxima
		tempo_ate_velocidade_maxima = config.tempo_ate_velocidade_maxima
	else:
		velocidade_inicial = VELOCIDADE_INICIAL
		velocidade_maxima = VELOCIDADE_MAXIMA
		velocidade_projetil_inicial = VELOCIDADE_PROJETIL_INICIAL
		velocidade_projetil_maxima = VELOCIDADE_PROJETIL_MAXIMA
		tempo_ate_velocidade_maxima = TEMPO_ATE_VELOCIDADE_MAXIMA
	tempo_corrida = 0.0
	progresso_dificuldade = 0.0
	velocidade_atual = velocidade_inicial
