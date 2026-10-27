extends TextureButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not pressed.is_connected(back):
		pressed.connect(back)


func back() -> void:
	disabled = true

	var som: AudioStreamPlayer = $Audio_botoes
	som.process_mode = Node.PROCESS_MODE_ALWAYS
	som.reparent(get_tree().root)
	som.finished.connect(som.queue_free)
	som.play()

	get_tree().paused = false
	get_tree().change_scene_to_file(
        "res://Contexts/MenuHomeContext/MenuHomeContext.tscn"
	)
