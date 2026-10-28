extends AudioStreamPlayer

var volume_original_db: float

func _ready() -> void:
	volume_original_db = volume_db

func diminuir_volume() -> void:
	volume_db = volume_original_db - 10.0

func restaurar_volume() -> void:
	volume_db = volume_original_db
