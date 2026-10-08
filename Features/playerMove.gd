extends CharacterBody2D 

var pista_atual: int = 0
var largura_pista: float = 100.0
var posicao_centro_x: float = 0.0
var posicao_inicial_toque: Vector2
var tocando: bool = false
var limite_swipe: float = 30.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			tocando = true
			posicao_inicial_toque = event.position
		elif tocando and not event.pressed: 
			tocando = false
			var deslize = event.position.x - posicao_inicial_toque.x
			
			if abs(deslize) > limite_swipe:
				if deslize > 0:
					mover_direita()
				else:
					mover_esquerda()

	#Setas do Teclado 
	if event.is_action_pressed("ui_left"):
		mover_esquerda()
	elif event.is_action_pressed("ui_right"):
		mover_direita()

func mover_esquerda() -> void:
	if pista_atual > -1:
		pista_atual -= 1

func mover_direita() -> void:
	if pista_atual < 1:
		pista_atual += 1

func _process(delta: float) -> void:
	# Calcula para qual posição X o personagem deve ir
	var alvo_x = posicao_centro_x + (pista_atual * largura_pista)
	
	# Move o personagem suavemente usando lerp
	# O valor '15.0' é a velocidade da esquiva
	position.x = lerp(position.x, alvo_x, 15.0 * delta)
