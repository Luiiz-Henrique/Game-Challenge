extends TextureButton


func _ready() -> void:
	pressed.connect(_on_tentar_novamente)


func _on_tentar_novamente() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
