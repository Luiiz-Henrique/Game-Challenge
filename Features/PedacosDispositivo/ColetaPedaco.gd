class_name ColetaPedaco
extends Node

## Coloca o pedaço da fase na pista central e registra a coleta quando o
## Xicó passa por ele. A animação de subida do Xicó é a do FinalLevel; este
## nó só observa a posição do player, sem mexer nela.

const CENA_ITEM: PackedScene = preload("res://Features/PedacosDispositivo/PedacoItem.tscn")

## Altura (y) onde o pedaço fica, entre o Xicó e o topo da tela.
const POSICAO_Y := 450.0

var _player: Node2D
var _numero_fase: int
var _item: PedacoItem


func _ready() -> void:
	set_process(false)


func iniciar(player: Node2D, numero_fase: int) -> void:
	var textura := PedacosDispositivo.textura_da_fase(numero_fase)
	# Fase sem pedaço (final) ou já coletada: o pedaço não aparece.
	if textura == null or PedacosDispositivo.foi_coletado(numero_fase):
		queue_free()
		return

	_player = player
	_numero_fase = numero_fase
	_item = CENA_ITEM.instantiate() as PedacoItem
	_item.configurar(textura)
	_item.position = Vector2(GameState.PISTAS_X[1], POSICAO_Y)
	get_parent().add_child(_item)
	_item.aparecer()
	set_process(true)


func _process(_delta: float) -> void:
	if not is_instance_valid(_player) or not is_instance_valid(_item):
		set_process(false)
		return
	if _player.global_position.y <= _item.global_position.y:
		set_process(false)
		PedacosDispositivo.registrar(_numero_fase)
		_item.coletar()
