
extends TextureRect

var is_paused := false

# Estado dos botões
var som_mutado := false
var musica_mutada := false

# Índices dos barramentos
var bus_master: int
var bus_music: int
var bus_ambience: int
var bus_sfx: int


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Localiza os barramentos
	bus_master = AudioServer.get_bus_index("Master")
	bus_music = AudioServer.get_bus_index("Music")
	bus_ambience = AudioServer.get_bus_index("Ambience")
	bus_sfx = AudioServer.get_bus_index("SFX")

	if bus_master == -1 or bus_music == -1 \
	or bus_ambience == -1 or bus_sfx == -1:
		push_error("Confira os barramentos de áudio.")
		return

	# Configura os botões
	_configurar_botao($BotaoSom, false)
	_configurar_botao($BotaoMusic, false)

	# Recupera os estados atuais
	som_mutado = (
		AudioServer.is_bus_mute(bus_ambience)
		and AudioServer.is_bus_mute(bus_sfx)
	)

	musica_mutada = AudioServer.is_bus_mute(bus_music)

	# Atualiza o estado visual
	$BotaoSom.set_pressed_no_signal(som_mutado)
	$BotaoMusic.set_pressed_no_signal(musica_mutada)

	# Conecta os sinais
	$BotaoSom.toggled.connect(_on_botao_som_toggled)
	$BotaoMusic.toggled.connect(_on_botao_music_toggled)


func _configurar_botao(botao: TextureButton, estado: bool) -> void:
	botao.toggle_mode = true
	botao.set_pressed_no_signal(estado)


# ==================================
# PAUSE
# ==================================

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		is_paused = !is_paused

		get_tree().paused = is_paused

		if is_paused:
			show()
		else:
			hide()


# ==================================
# RETOMAR
# ==================================

func _on_button_retomar_pause_pressed() -> void:
	is_paused = false
	get_tree().paused = false
	hide()


# ==================================
# SAIR
# ==================================

func _on_button_sair_pause_pressed() -> void:
	$ButtonSairPause.disabled = true

	var som: AudioStreamPlayer = $ButtonSairPause/Audio_botoes
	som.process_mode = Node.PROCESS_MODE_ALWAYS
	som.reparent(get_tree().root)
	som.finished.connect(som.queue_free)
	som.play()

	get_tree().paused = false

	get_tree().change_scene_to_file(
		"res://Contexts/MapaContext/MapaContext.tscn"
	)


# ==================================
# BOTÃO SOM
# ==================================

func _on_botao_som_toggled(ativado: bool) -> void:
	som_mutado = ativado

	AudioServer.set_bus_mute(bus_ambience, ativado)
	AudioServer.set_bus_mute(bus_sfx, ativado)


# ==================================
# BOTÃO MUSIC
# ==================================

func _on_botao_music_toggled(ativado: bool) -> void:
	musica_mutada = ativado

	AudioServer.set_bus_mute(bus_music, ativado)
