class_name Pedra
extends Node2D

## Feature de obstáculo (pedra) posicionada sobre a pista.
## Não possui autonomia: o GameContext injeta a velocidade chamando mover()
## a cada frame. Ao colidir com o jogador apenas emite um sinal (signal up);
## a feature não conhece o estado do jogo, não acessa nós superiores e não
## decide game over.

signal player_atingido

@onready var area_detecao: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D

const tela_morte = preload("res://Features/Pedra/Pedra.tscn")

func _ready() -> void:
	area_detecao.body_entered.connect(_on_area_2d_body_entered)
	_reposicionar()



## Troca a arte do obstáculo (cacto, pedra...) mantendo a largura na tela.
func configurar_textura(textura: Texture2D) -> void:
	if textura == null or textura == sprite.texture:
		return
	var largura_na_tela: float = sprite.texture.get_size().x * sprite.scale.x
	sprite.texture = textura
	sprite.scale = Vector2.ONE * (largura_na_tela / textura.get_size().x)


## Tira o obstáculo da fase: some da tela e deixa de colidir.
func desativar() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


## Método público orquestrado pelo GameContext (call down).
func mover(delta: float, velocidade_atual: float) -> void:
	position.y += velocidade_atual * delta
	if position.y > get_viewport_rect().size.y + 100:
		_reposicionar()


func _reposicionar() -> void:
	position.y = -100.0
	position.x = float(GameState.PISTAS_X.pick_random())


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_atingido.emit()
