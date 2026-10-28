class_name PedacoItem
extends Sprite2D

## Pedaço do dispositivo colocado na pista no fim da fase.
## Só anima e avisa quando foi coletado (signal up); quem decide o momento
## da coleta é a ColetaPedaco.

signal coletado

const DURACAO_APARECER := 0.3
const DURACAO_COLETAR := 0.3
const ESCALA_COLETA := 1.8


func configurar(textura: Texture2D) -> void:
	texture = textura


func aparecer() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, DURACAO_APARECER)


## Cresce e some ao mesmo tempo, depois se libera.
func coletar() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", scale * ESCALA_COLETA, DURACAO_COLETAR).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, DURACAO_COLETAR)
	tween.chain().tween_callback(func():
		coletado.emit()
		queue_free()
	)
