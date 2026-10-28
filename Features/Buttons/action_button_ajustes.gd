extends TextureRect

@export var volume_do_jogo: HSlider
@export var volume_da_musica: HSlider
@export var silenciar: TextureButton
@export var silenciar_musica: TextureButton

var bus_master: int
var bus_music: int


func _ready() -> void:
	if not _validar_controles():
		return

	bus_master = AudioServer.get_bus_index("Master")
	bus_music = AudioServer.get_bus_index("Music")

	if bus_master == -1 or bus_music == -1:
		push_error("Confira os barramentos Master e Music no painel Áudio.")
		return

	_configurar_slider(volume_do_jogo, bus_master)
	_configurar_slider(volume_da_musica, bus_music)

	_configurar_botao(silenciar, bus_master)
	_configurar_botao(silenciar_musica, bus_music)

	volume_do_jogo.value_changed.connect(_on_volume_do_jogo_changed)
	volume_da_musica.value_changed.connect(_on_volume_da_musica_changed)

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


func _configurar_slider(slider: HSlider, bus: int) -> void:
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0

	slider.set_value_no_signal(
		AudioServer.get_bus_volume_linear(bus) * 100.0
	)


func _configurar_botao(botao: TextureButton, bus: int) -> void:
	botao.toggle_mode = true
	botao.set_pressed_no_signal(
		AudioServer.is_bus_mute(bus)
	)


func _on_volume_do_jogo_changed(valor: float) -> void:
	AudioServer.set_bus_volume_linear(bus_master, valor / 100.0)


func _on_volume_da_musica_changed(valor: float) -> void:
	AudioServer.set_bus_volume_linear(bus_music, valor / 100.0)


func _on_silenciar_toggled(ativado: bool) -> void:
	AudioServer.set_bus_mute(bus_master, ativado)


func _on_silenciar_musica_toggled(ativado: bool) -> void:
	AudioServer.set_bus_mute(bus_music, ativado)
