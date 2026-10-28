class_name PedacosDispositivo
extends RefCounted

## Guarda quais pedaços do dispositivo o jogador já coletou.
## Fica salvo no mesmo arquivo do ProgressoFases, numa seção própria, para o
## progresso sobreviver entre sessões. Cada fase com pedaço conta uma vez só.

const CAMINHO_ARQUIVO := "user://progresso.cfg"
const SECAO := "pedacos"
const CHAVE_COLETADOS := "fases_coletadas"

const TOTAL := 3

## Pedaço de cada fase, na ordem: índice 0 = fase 1. A fase final não tem pedaço.
const TEXTURAS: Array[Texture2D] = [
	preload("res://Features/PedacosDispositivo/Elementos/pedaco-fase1.png"),
	preload("res://Features/PedacosDispositivo/Elementos/pedaco-fase2.png"),
	preload("res://Features/PedacosDispositivo/Elementos/pedaco-fase3.png"),
]


## Textura do pedaço da fase, ou null se a fase não tiver pedaço.
static func textura_da_fase(numero_fase: int) -> Texture2D:
	var indice := numero_fase - 1
	if indice < 0 or indice >= TEXTURAS.size():
		return null
	return TEXTURAS[indice]


static func foi_coletado(numero_fase: int) -> bool:
	return numero_fase in _fases_coletadas()


static func quantidade() -> int:
	return _fases_coletadas().size()


static func esta_completo() -> bool:
	return quantidade() >= TOTAL


## Registra o pedaço da fase. Rejogar uma fase já coletada não conta de novo.
static func registrar(numero_fase: int) -> void:
	if textura_da_fase(numero_fase) == null or foi_coletado(numero_fase):
		return
	var config := ConfigFile.new()
	config.load(CAMINHO_ARQUIVO)
	var coletadas := _fases_coletadas()
	coletadas.append(numero_fase)
	config.set_value(SECAO, CHAVE_COLETADOS, coletadas)
	var erro := config.save(CAMINHO_ARQUIVO)
	if erro != OK:
		push_error("[PedacosDispositivo] Falha ao salvar %s (erro %d)." % [CAMINHO_ARQUIVO, erro])


## Apaga só os pedaços, sem mexer no progresso das fases (útil em testes).
static func resetar() -> void:
	var config := ConfigFile.new()
	if config.load(CAMINHO_ARQUIVO) != OK or not config.has_section(SECAO):
		return
	config.erase_section(SECAO)
	config.save(CAMINHO_ARQUIVO)


static func _fases_coletadas() -> Array:
	var config := ConfigFile.new()
	if config.load(CAMINHO_ARQUIVO) != OK:
		return []
	return config.get_value(SECAO, CHAVE_COLETADOS, [])
