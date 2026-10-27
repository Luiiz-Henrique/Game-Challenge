extends TextureRect

var is_paused = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _input(event: InputEvent) -> void: 
	if Input.is_action_just_pressed("pause"):
		if Input.is_action_just_pressed("Pausa"):
			is_paused = !is_paused
		if is_paused:
			get_tree().paused = true
			show()
		else:
			get_tree().paused = false
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
