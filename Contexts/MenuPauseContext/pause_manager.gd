
extends TextureRect

var is_paused := false

# Estado dos botões
var som_mutado := false
var musica_mutada := false

# Índices dos barramentos
var bus_music: int
var bus_sfx: int


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_configurar_barramentos()

	if bus_music == -1 or bus_sfx == -1:
		push_error("Confira os barramentos Music e SFX no painel Áudio.")
		return

	_configurar_botoes_audio()
	_recuperar_estado_audio()
	_conectar_sinais()




func _configurar_barramentos() -> void:
	bus_music = AudioServer.get_bus_index("Music")
	bus_sfx = AudioServer.get_bus_index("SFX")



func _configurar_botoes_audio() -> void:
	$BotaoSom.toggle_mode = true
	$BotaoMusic.toggle_mode = true


func _recuperar_estado_audio() -> void:
	som_mutado = AudioServer.is_bus_mute(bus_sfx)
	musica_mutada = AudioServer.is_bus_mute(bus_music)

	$BotaoSom.set_pressed_no_signal(som_mutado)
	$BotaoMusic.set_pressed_no_signal(musica_mutada)


func _conectar_sinais() -> void:
	if not $BotaoSom.toggled.is_connected(_on_botao_som_toggled):
		$BotaoSom.toggled.connect(_on_botao_som_toggled)

	if not $BotaoMusic.toggled.is_connected(_on_botao_music_toggled):
		$BotaoMusic.toggled.connect(_on_botao_music_toggled)




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		is_paused = !is_paused
		get_tree().paused = is_paused

		if is_paused:
			show()
		else:
			hide()



func _on_button_retomar_pause_pressed() -> void:
	is_paused = false
	get_tree().paused = false
	hide()



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



func _on_botao_som_toggled(ativado: bool) -> void:
	som_mutado = ativado


	AudioServer.set_bus_mute(bus_sfx, ativado)


func _on_botao_music_toggled(ativado: bool) -> void:
	musica_mutada = ativado

	AudioServer.set_bus_mute(bus_music, ativado)
