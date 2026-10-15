class_name Pedra
extends Node2D

## Feature de obstáculo (pedra) posicionada sobre a pista.
## Não possui autonomia: o GameContext injeta a velocidade chamando mover()
## a cada frame. Ao colidir com o jogador apenas emite um sinal (signal up);
## a feature não conhece o estado do jogo, não acessa nós superiores e não
## decide game over.

signal player_atingido

var pistas_x: Array = [111.0, 201.0, 291.0]

@onready var area_detecao: Area2D = $Area2D


func _ready() -> void:
	area_detecao.body_entered.connect(_on_area_2d_body_entered)
	_reposicionar()


## Método público orquestrado pelo GameContext (call down).
func mover(delta: float, velocidade_atual: float) -> void:
	position.y += velocidade_atual * delta
	if position.y > get_viewport_rect().size.y + 100:
		_reposicionar()


func _reposicionar() -> void:
	position.y = -100.0
	position.x = pistas_x.pick_random()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_atingido.emit()
