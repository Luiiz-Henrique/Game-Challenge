class_name TutorialProgresso
extends RefCounted

## Guarda se o jogador já assistiu ao storytelling inicial.
## Fica salvo em disco para o tutorial aparecer só no primeiro jogo.

const CAMINHO_ARQUIVO := "user://tutorial.cfg"
const SECAO := "tutorial"
const CHAVE_VISTO := "visto"


## true enquanto o jogador ainda não terminou o tutorial.
static func deve_exibir() -> bool:
	var config := ConfigFile.new()
	if config.load(CAMINHO_ARQUIVO) != OK:
		return true
	return not config.get_value(SECAO, CHAVE_VISTO, false)


static func marcar_visto() -> void:
	var config := ConfigFile.new()
	config.load(CAMINHO_ARQUIVO)
	config.set_value(SECAO, CHAVE_VISTO, true)
	var erro := config.save(CAMINHO_ARQUIVO)
	if erro != OK:
		push_error("[TutorialProgresso] Falha ao salvar %s (erro %d)." % [CAMINHO_ARQUIVO, erro])


## Apaga o progresso para o tutorial voltar a aparecer (útil em testes).
static func resetar() -> void:
	if FileAccess.file_exists(CAMINHO_ARQUIVO):
		DirAccess.remove_absolute(CAMINHO_ARQUIVO)
