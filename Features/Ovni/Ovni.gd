class_name ProjetilOvni
extends Node2D

var projetil_ovni = preload("res://Features/Ovni/Projetil.tscn")
var valores_spawner = [122, 205, 288]

@onready var disparo_ovni: Timer = $Timer

func disparos_por_segundo(delta: float, velocidade_atual: float) -> void:
	disparo_ovni.wait_time = move_toward(disparo_ovni.wait_time, 0.5, 0.01 * delta)

func _on_atack_timer_timeout():
	# 1. Cria a instância do fogo
	var novo_projetil = projetil_ovni.instantiate()
	
	# 2. Adiciona o fogo na cena principal (Fase_1)
	get_tree().current_scene.add_child(novo_projetil)
	
	
	# 3. Sorteia uma das 3 pistas
	var pista_alvo = valores_spawner.pick_random()
	
	# 4. Define a posição inicial do fogo:
	# O 'X' será exatamente a pista sorteada.
	# O 'Y' será exatamente a posição atual da boca do dragão.
	novo_projetil.global_position = Vector2(pista_alvo, self.global_position.y)
	global_position.x = pista_alvo
