class_name FinalLevel
extends Node

## Nó responsável por orquestrar toda a sequência visual de encerramento da fase.
## Pode ser invocado por qualquer orquestrador de fase (ex: GameContext) via
## iniciar_finalizacao(...), de forma desacoplada, passando os parâmetros necessários.



const CENA_POPUP: PackedScene = preload("res://Features/PopupFinalizacao/PopupFinalizacao.tscn")

## Referências mantidas durante a sequência de encerramento.
var _player: Node2D
var _ovni: Node2D
var _item_scene: PackedScene
var _proxima_cena_path: String
var _tween_atual: Tween


## Inicia a sequência de encerramento da fase.
##
## Parâmetros:
##   - player: nó do jogador (Node2D) que será movido para o topo.
##   - ovni: nó do OVNI (Node2D) que será removido da vista.
##   - item_scene: PackedScene do item a ser instanciado no caminho do Player.
##   - proxima_cena_path: caminho da cena a ser carregada no PopupFinalizacao.
##   - elementos_hud: elementos de interface (ex: barra de progresso, botão de
##     pause) que devem sumir assim que a animação começar.
func iniciar_finalizacao(player: CharacterBody2D, ovni: Node2D, proxima_cena_path: String, elementos_hud: Array[CanvasItem] = []) -> void: #item_scene: PackedScene
	if not is_inside_tree():
		return

	_player = player
	_ovni = ovni
	#_item_scene = item_scene
	_proxima_cena_path = proxima_cena_path

	# 1. Bloquear os controles manuais do Player e interromper atualização de pista.
	_bloquear_controles_player(player, true)


	# 3. Remover obstáculos (pedra e projéteis) para que nada atinja o Player
	# durante a animação, já que ele não pode mais desviar.
	_remover_obstaculos()

	# 4. Esconder a HUD (barra de progresso, botão de pause...).
	_esconder_hud(elementos_hud)

	# Inicia a sequência visual: primeiro move o Ovni para fora da vista (topo).
	_mover_ovni_para_topo()


## Etapa 2: move o Ovni via Tween para o topo da tela até sair completamente de vista.
func _mover_ovni_para_topo() -> void:
	#var jogador_altura: float = _player.get_global_rect().size.y
	var ovni_saida_y: float = -200

	_tween_atual = create_tween()
	_tween_atual.tween_property(_ovni, "global_position:y", ovni_saida_y, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween_atual.finished.connect(_mover_player_para_pista_central)


## Etapa 3: move o Player em direção à pista central (PISTAS_X[1])
## enquanto se desloca continuamente para o topo da tela.
func _mover_player_para_pista_central() -> void:
	if not is_inside_tree():
		return

	var pista_central_x: float = GameState.PISTAS_X[1]  # elemento central (201.0)
	#var player_altura: float = _player.get_global_rect().size.y
	var player_saida_y: float = -200  # totalmente fora da tela (topo)

	_tween_atual = create_tween()
	# Alinha o Player na pista central.
	_tween_atual.tween_property(_player, "global_position:x", pista_central_x, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Desloca o Player continuamente para o topo até sair da vista.
	_tween_atual.tween_property(_player, "global_position:y", player_saida_y, 2.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_tween_atual.finished.connect(_instanciar_item_no_caminho)


## Etapa 4: instancia o item_scene no caminho do Player (perto do topo, na pista central)
## para que ele colete o item antes de desaparecer da tela.
func _instanciar_item_no_caminho() -> void:
	if not is_inside_tree():
		return

	if _item_scene:
		var item: Node2D = _item_scene.instantiate() as Node2D
		var pista_central_x: float = GameState.PISTAS_X[1]
		item.global_position = Vector2(pista_central_x, -80.0)
		item.z_index = 10
		get_tree().current_scene.add_child(item)

	# Pequena pausa para o player "coletar" visualmente o item antes de sair.
	var timer_espera: Timer = Timer.new()
	timer_espera.one_shot = true
	timer_espera.wait_time = 0.8
	timer_espera.timeout.connect(func():
		timer_espera.queue_free()
		_mostrar_popup("res://Contexts/MenuHomeContext/MenuHomeContext.tscn")
		#add_child(CENA_POPUP.instantiate())
	)
	add_child(timer_espera)
	timer_espera.start()



## Etapa 5: quando o Player saiu totalmente da tela, exibe o PopupFinalizacao
## injetando a proxima_cena_path.
func _mostrar_popup(proxima_cena_path: String) -> void:
	var popup: PopupFinalizacao = CENA_POPUP.instantiate() as PopupFinalizacao
	popup.configurar(proxima_cena_path)
	get_tree().current_scene.add_child(popup)


## Remove da cena os projéteis existentes e desativa a pedra. Também passa a
## observar a árvore para descartar projéteis que ainda nasçam depois disso
## (o Ovni pode estar no meio do deslocamento quando isAttack vira false).
func _remover_obstaculos() -> void:
	var cena: Node = get_tree().current_scene
	# Busca recursiva: a pedra é filha do GameContext, que pode não ser a raiz.
	for no in cena.find_children("*", "", true, false):
		if no is Projetil:
			_remover_projetil(no)
		elif no is Pedra:
			_desativar_pedra(no)

	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)


func _on_node_added(no: Node) -> void:
	if no is Projetil:
		_remover_projetil(no)


## Desliga a colisão imediatamente e faz um fade rápido antes de liberar o nó.
func _remover_projetil(projetil: Projetil) -> void:
	projetil.set_deferred("monitoring", false)
	projetil.set_deferred("monitorable", false)
	var tween: Tween = projetil.create_tween()
	tween.tween_property(projetil, "modulate:a", 0.0, 0.2)
	tween.tween_callback(projetil.queue_free)


## A pedra não é liberada: o GameContext continua chamando pedra.mover() a cada
## frame. Ela apenas fica invisível e sem colisão (process_mode desativado
## remove a Area2D filha da física).
func _desativar_pedra(pedra: Pedra) -> void:
	pedra.process_mode = Node.PROCESS_MODE_DISABLED
	var tween: Tween = create_tween()
	tween.tween_property(pedra, "modulate:a", 0.0, 0.2)
	tween.tween_callback(pedra.hide)


## Desativa a interação imediatamente (evita pausar durante a animação) e
## faz um fade antes de esconder cada elemento.
func _esconder_hud(elementos_hud: Array[CanvasItem]) -> void:
	for elemento in elementos_hud:
		if not is_instance_valid(elemento):
			continue
		if elemento is BaseButton:
			elemento.disabled = true
		if elemento is Control:
			elemento.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tween: Tween = create_tween()
		tween.tween_property(elemento, "modulate:a", 0.0, 0.3)
		tween.tween_callback(elemento.hide)


## Bloqueia/desbloqueia os controles do Player via método auxiliar, quando disponível.
func _bloquear_controles_player(player: Node2D, bloqueado: bool) -> void:
	if player.has_method("bloquear_controles"):
		player.bloquear_controles(bloqueado)


func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.disconnect(_on_node_added)
	if _tween_atual and _tween_atual.is_running():
		_tween_atual.kill()
