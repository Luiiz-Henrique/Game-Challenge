extends Node

var game_center: GameCenterManager


func _ready() -> void:
	game_center = GameCenterManager.new()

	game_center.authentication_error.connect(_ao_falhar_autenticacao)
	game_center.authentication_result.connect(_ao_receber_autenticacao)

	game_center.authenticate()


func _ao_falhar_autenticacao(erro: String) -> void:
	print("Erro no Game Center: ", erro)


func _ao_receber_autenticacao(autenticado: bool) -> void:
	if autenticado:
		print("Game Center: jogador autenticado!")
	else:
		print("Game Center: jogador não autenticado.")
