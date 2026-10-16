class_name Projetil
extends Area2D

## Projétil disparado pelo Ovni sobre uma das pistas.
## Não possui autonomia: o Ovni (seu dono) injeta o movimento via mover()
## a cada frame (call down). Ao encostar no jogador apenas emite
## atingiu_player (signal up); não decide game over nem acessa nós acima.

signal atingiu_player


## Método público orquestrado pelo Ovni (call down).
func mover(delta: float, velocidade: float) -> void:
	position.y += velocidade * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		atingiu_player.emit()
