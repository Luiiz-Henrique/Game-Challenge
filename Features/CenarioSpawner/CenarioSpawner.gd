class_name CenarioSpawner
extends Node2D

## Feature de geração infinita de cenário.
## Não possui autonomia de movimento: o orquestrador pai (GameContext)
## injeta a velocidade do GameState chamando mover_cenario() a cada frame.

signal bloco_reciclado


enum ModoGeracao { SEQUENCIAL, ALEATORIO }
@export var modo_atual: ModoGeracao = ModoGeracao.SEQUENCIAL

# ARRAY EXPORTADO: Receberá as cenas (.tscn) específicas de cada fase via Inspector
@export var lista_de_blocos: Array[PackedScene]

# Suporte a transição para Fase 3 (início -> meio/final)
@export var usar_transicao: bool = false
@export var lista_inicio: Array[PackedScene]
@export var lista_fim: Array[PackedScene]
@export var progresso_transicao: float = 0.5  # 0.0 a 1.0, quando atingir troca de lista

var blocos_ativos: Array = []
var altura_do_bloco: float = 874.0 # Mantido conforme a lógica vertical do projeto
var indice_sequencia: int = 0
var ja_trocou: bool = false
var lista_atual: Array[PackedScene] = []


func _ready() -> void:
	if usar_transicao:
		if lista_inicio.is_empty():
			push_warning("A lista_inicio do CenarioSpawner está vazia!")
			return
		lista_atual = lista_inicio
	else:
		if lista_de_blocos.is_empty():
			push_warning("A lista_de_blocos do CenarioSpawner está vazia!")
			return
		lista_atual = lista_de_blocos

	criar_novo_bloco(0.0)
	criar_novo_bloco(-altura_do_bloco)
	criar_novo_bloco(-altura_do_bloco * 2)


## Método público orquestrado pelo GameContext (call down).
## Recebe delta e a velocidade atual do GameState a cada frame.
func mover_cenario(delta: float, velocidade_atual: float) -> void:
	for bloco in blocos_ativos:
		bloco.position.y += velocidade_atual * delta
	_verificar_reciclagem()
	_verificar_transicao()


func _verificar_transicao() -> void:
	if not usar_transicao or ja_trocou:
		return
	if lista_fim.is_empty():
		return
	# Tenta obter progresso da barra de progressão
	var progresso = 0.0
	var tree = get_tree()
	if tree:
		var barra = tree.get_first_node_in_group("barra_progressao")
		if barra and barra.has_method("get_progresso"):
			progresso = barra.get_progresso()
		else:
			# Fallback: tenta encontrar BarraProgressaoMap
			var root = tree.current_scene
			if root:
				var barra_node = root.find_child("BarraProgressaoMap", true, false)
				if barra_node and barra_node.has_method("get_progresso"):
					progresso = barra_node.get_progresso()
	if progresso >= progresso_transicao:
		lista_atual = lista_fim
		ja_trocou = true


func criar_novo_bloco(posicao_y: float) -> void:
	if lista_atual.is_empty():
		return
	var bloco_escolhido
	if modo_atual == ModoGeracao.SEQUENCIAL:
		bloco_escolhido = lista_atual[indice_sequencia]
		indice_sequencia = (indice_sequencia + 1) % lista_atual.size()
	elif modo_atual == ModoGeracao.ALEATORIO:
		bloco_escolhido = lista_atual.pick_random()

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
