class_name Projetil
extends Area2D

## Projétil disparado pelo Ovni sobre uma das pistas.
## Não possui autonomia: o Ovni (seu dono) injeta o movimento via mover()
## a cada frame (call down). Ao encostar no jogador apenas emite
## atingiu_player (signal up); não decide game over nem acessa nós acima.

signal player_atingido
#
#
### Método público orquestrado pelo Ovni (call down).
#func mover(delta: float, velocidade: float) -> void:
	#position.y += velocidade * delta
#
#
#func _on_body_entered(body: Node2D) -> void:
	#if body is Player:
		#atingiu_player.emit()

var velocidade_projetil = GameState.velocidade_atual * 1.2 #Fogo mais rápido que o cenário para chegar no jogador.

func _process(delta: float) -> void:
	global_position.y += velocidade_projetil * delta # Move o fogo na direção vertical (pra cima)
	
	#if global_position.y < -100: #Fogo some ao sair da tela (passar do jogador)
	#	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Você morreu")
		player_atingido.emit()
		queue_free()
		
