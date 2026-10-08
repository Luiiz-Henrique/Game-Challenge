class_name CenarioSpawner
extends Node2D

## Feature de geração infinita de cenário.
## Não possui autonomia de movimento: o orquestrador pai (GameContext)
## injeta a velocidade do GameState chamando mover_cenario() a cada frame.

signal bloco_reciclado

enum ModoGeracao { SEQUENCIAL, ALEATORIO }
@export var modo_atual: ModoGeracao = ModoGeracao.SEQUENCIAL

var bloco_1 = preload("res://Features/Cenarios/CenarioInverno.tscn")
var bloco_2 = preload("res://Features/Cenarios/CenarioOutono.tscn")
var bloco_3 = preload("res://Features/Cenarios/CenarioVerao.tscn")


var lista_de_blocos: Array
var blocos_ativos: Array = []
var altura_do_bloco: float = 874.0
var indice_sequencia: int = 0


func _ready() -> void:
	lista_de_blocos = [bloco_1, bloco_2, bloco_3]
	criar_novo_bloco(0.0)
	criar_novo_bloco(-altura_do_bloco)
	criar_novo_bloco(-altura_do_bloco * 2)


## Método público orquestrado pelo GameContext (call down).
## Recebe delta e a velocidade atual do GameState a cada frame.
func mover_cenario(delta: float, velocidade_atual: float) -> void:
	for bloco in blocos_ativos:
		bloco.position.y += velocidade_atual * delta
	_verificar_reciclagem()


func criar_novo_bloco(posicao_y: float) -> void:
	var bloco_escolhido
	if modo_atual == ModoGeracao.SEQUENCIAL:
		bloco_escolhido = lista_de_blocos[indice_sequencia]
		indice_sequencia = (indice_sequencia + 1) % lista_de_blocos.size()
	elif modo_atual == ModoGeracao.ALEATORIO:
		bloco_escolhido = lista_de_blocos.pick_random()

	var nova_instancia = bloco_escolhido.instantiate()
	nova_instancia.position.y = posicao_y
	nova_instancia.position.x = 0.0

	add_child(nova_instancia)
	blocos_ativos.append(nova_instancia)


## Recicla o bloco mais antigo quando ele sai da tela,
## posicionando o novo bloco exatamente após o último (sem buracos).
func _verificar_reciclagem() -> void:
	if blocos_ativos.size() > 0:
		var bloco_mais_antigo = blocos_ativos[0]
		if bloco_mais_antigo.position.y > get_viewport_rect().size.y:
			var ultimo_bloco = blocos_ativos[-1]
			var nova_posicao_y = ultimo_bloco.position.y - altura_do_bloco
			bloco_mais_antigo.queue_free()
			blocos_ativos.pop_front()
			criar_novo_bloco(nova_posicao_y)
			bloco_reciclado.emit()
