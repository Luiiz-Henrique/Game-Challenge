
extends TextureRect

@export var volume_do_jogo: HSlider
@export var volume_da_musica: HSlider
@export var silenciar: TextureButton
@export var silenciar_musica: TextureButton

# Índices dos barramentos
var bus_sfx: int
var bus_music: int


func _ready() -> void:
	if not _validar_controles():
		return

	# Recupera os barramentos
	bus_sfx = AudioServer.get_bus_index("SFX")
	bus_music = AudioServer.get_bus_index("Music")

	if bus_sfx == -1 or bus_music == -1:
		push_error("Confira os barramentos SFX e Music no painel Áudio.")
		return

	# Configura os sliders
	_configurar_slider(volume_do_jogo, bus_sfx)
	_configurar_slider(volume_da_musica, bus_music)

	# Configura os botões de mute
	_configurar_botao(silenciar, bus_sfx)
	_configurar_botao(silenciar_musica, bus_music)

	# Conecta os sinais dos sliders
	volume_do_jogo.value_changed.connect(_on_volume_do_jogo_changed)
	volume_da_musica.value_changed.connect(_on_volume_da_musica_changed)

	# Conecta os sinais dos botões
	silenciar.toggled.connect(_on_silenciar_toggled)
	silenciar_musica.toggled.connect(_on_silenciar_musica_toggled)


func _validar_controles() -> bool:
	if volume_do_jogo == null or volume_da_musica == null:
		push_error("Associe as duas barras no Inspetor de MenuAjustes.")
		return false

	if silenciar == null or silenciar_musica == null:
		push_error("Associe os dois botões no Inspetor de MenuAjustes.")
		return false

	return true


# CONFIGURAÇÃO DOS SLIDERS

func _configurar_slider(slider: HSlider, bus: int) -> void:
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0

	slider.set_value_no_signal(
		AudioServer.get_bus_volume_linear(bus) * 100.0
	)


# CONFIGURAÇÃO DOS BOTÕES

func _configurar_botao(botao: TextureButton, bus: int) -> void:
	botao.toggle_mode = true

	botao.set_pressed_no_signal(
		AudioServer.is_bus_mute(bus)
	)


# SLIDER SOM - SFX

func _on_volume_do_jogo_changed(valor: float) -> void:
	AudioServer.set_bus_volume_linear(bus_sfx, valor / 100.0)


# SLIDER MÚSICA - MUSIC

func _on_volume_da_musica_changed(valor: float) -> void:
	AudioServer.set_bus_volume_linear(bus_music, valor / 100.0)


# BOTÃO SOM - SFX

func _on_silenciar_toggled(ativado: bool) -> void:
	AudioServer.set_bus_mute(bus_sfx, ativado)


# BOTÃO MÚSICA - MUSIC

func _on_silenciar_musica_toggled(ativado: bool) -> void:
	AudioServer.set_bus_mute(bus_music, ativado)
