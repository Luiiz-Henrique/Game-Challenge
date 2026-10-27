extends TextureButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not pressed.is_connected(_on_tentar_novamente):
		pressed.connect(_on_tentar_novamente)


func _on_tentar_novamente() -> void:
	disabled = true

	var som: AudioStreamPlayer = $Audio_botoes
	som.process_mode = Node.PROCESS_MODE_ALWAYS
	som.reparent(get_tree().root)
	som.finished.connect(som.queue_free)
	som.play()

	get_tree().paused = false
	get_tree().reload_current_scene()
