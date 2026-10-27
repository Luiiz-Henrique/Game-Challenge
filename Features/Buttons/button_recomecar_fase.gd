extends TextureButton

@onready var audio_botoes: AudioStreamPlayer = $Audio_botoes


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not pressed.is_connected(_reiniciar_fase):
		pressed.connect(_reiniciar_fase)


func _reiniciar_fase() -> void:
	disabled = true

	# Mantém o clique tocando durante o recarregamento.
	audio_botoes.process_mode = Node.PROCESS_MODE_ALWAYS
	audio_botoes.reparent(get_tree().root)
	audio_botoes.finished.connect(audio_botoes.queue_free)
	audio_botoes.play()

	get_tree().paused = false
	get_tree().reload_current_scene()
