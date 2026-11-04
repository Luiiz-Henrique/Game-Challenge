class_name Obstaculos
extends Node2D

## Feature que mantém os obstáculos (cacto, pedra...) que estão na pista.
## Permite vários ao mesmo tempo, como numa dupla. Não decide onde nem
## quando surgem: o GameContext chama criar() e mover() (call down). Ao
## colidir com o jogador apenas repassa o sinal da Pedra (signal up).

signal player_atingido

const CENA_PEDRA := preload("res://Features/Pedra/Pedra.tscn")

## Altura (y) onde todo obstáculo surge, logo acima da tela.
const Y_SURGIMENTO: float = -100.0

## Escala aplicada a cada obstáculo criado.
@export var escala: float = 0.7

var _textura: Texture2D
var _ativo: bool = true


## Arte dos obstáculos desta fase. Vazio mantém a da cena Pedra.
func configurar_textura(textura: Texture2D) -> void:
	_textura = textura


## Fase sem obstáculos: nada mais é criado.
func desativar() -> void:
	_ativo = false
	hide()


func esta_vazio() -> bool:
	return get_child_count() == 0


func criar(pista_x: float) -> void:
	if not _ativo:
		return
	var pedra: Pedra = CENA_PEDRA.instantiate()
	pedra.scale = Vector2.ONE * escala
	pedra.position = Vector2(pista_x, Y_SURGIMENTO)
	add_child(pedra)
	pedra.configurar_textura(_textura)
	pedra.player_atingido.connect(player_atingido.emit)


## Método público orquestrado pelo GameContext (call down). Desce todos os
## obstáculos e libera os que já passaram do jogador.
func mover(delta: float, velocidade_atual: float) -> void:
	var limite: float = get_viewport_rect().size.y + 100.0
	for pedra in get_children():
		if pedra.is_queued_for_deletion():
			continue
		pedra.mover(delta, velocidade_atual)
		if pedra.position.y > limite:
			pedra.queue_free()
