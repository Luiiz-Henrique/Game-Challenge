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

# Escala própria do projétil (400 -> 900), seguindo o progresso da dificuldade.
var velocidade_projetil = lerpf(
	GameState.VELOCIDADE_PROJETIL_INICIAL,
	GameState.VELOCIDADE_PROJETIL_MAXIMA,
	GameState.progresso_dificuldade
)

func _process(delta: float) -> void:
	global_position.y += velocidade_projetil * delta

	# Some depois de passar do jogador e sair por baixo da tela.
	if global_position.y > get_viewport_rect().size.y + 100.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Você morreu")
		player_atingido.emit()
		queue_free()
		
