class_name ProgressoFases
extends RefCounted

## Guarda até qual fase o jogador já liberou no mapa.
## Fica salvo em disco para o progresso sobreviver entre sessões.
## A fase 1 está sempre liberada; concluir a fase N libera a fase N + 1.

const CAMINHO_ARQUIVO := "user://progresso.cfg"
const SECAO := "fases"
const CHAVE_DESBLOQUEADA := "ultima_desbloqueada"

const TOTAL_FASES := 4


## Número da maior fase liberada (1 a TOTAL_FASES).
static func ultima_desbloqueada() -> int:
	var config := ConfigFile.new()
	if config.load(CAMINHO_ARQUIVO) != OK:
		return 1
	return clampi(config.get_value(SECAO, CHAVE_DESBLOQUEADA, 1), 1, TOTAL_FASES)


static func esta_desbloqueada(numero_fase: int) -> bool:
	return numero_fase <= ultima_desbloqueada()


## Marca a fase como concluída, liberando a seguinte. Rejogar uma fase
## antiga nunca reduz o progresso.
static func concluir(numero_fase: int) -> void:
	var proxima := mini(numero_fase + 1, TOTAL_FASES)
	if proxima <= ultima_desbloqueada():
		return
	var config := ConfigFile.new()
	config.load(CAMINHO_ARQUIVO)
	config.set_value(SECAO, CHAVE_DESBLOQUEADA, proxima)
	var erro := config.save(CAMINHO_ARQUIVO)
	if erro != OK:
		push_error("[ProgressoFases] Falha ao salvar %s (erro %d)." % [CAMINHO_ARQUIVO, erro])


## Apaga o progresso, voltando a liberar só a fase 1 (útil em testes).
static func resetar() -> void:
	if FileAccess.file_exists(CAMINHO_ARQUIVO):
		DirAccess.remove_absolute(CAMINHO_ARQUIVO)
