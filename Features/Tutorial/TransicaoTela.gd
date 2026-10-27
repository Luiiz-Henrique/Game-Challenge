class_name TransicaoTela
extends CanvasLayer

## Fade pelo preto entre telas.
## Pode ser usada como nó filho (escurecer/clarear) ou pelo atalho estático
## trocar_cena, que sobrevive à troca de cena por ficar pendurada na root.

const DURACAO_PADRAO := 0.4

var _cortina: ColorRect


func _init() -> void:
	layer = 100
	_cortina = ColorRect.new()
	_cortina.color = Color.BLACK
	_cortina.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cortina.modulate.a = 0.0
	_cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cortina)


## Troca de cena com fade out -> change_scene -> fade in.
static func trocar_cena(arvore: SceneTree, caminho: String, duracao: float = DURACAO_PADRAO) -> void:
	var transicao := TransicaoTela.new()
	arvore.root.add_child(transicao)
	await transicao.escurecer(duracao)
	arvore.change_scene_to_file(caminho)
	await arvore.scene_changed
	await transicao.clarear(duracao)
	transicao.queue_free()


## Deixa a tela totalmente preta na hora, sem animação.
func cobrir() -> void:
	_cortina.modulate.a = 1.0
	_cortina.mouse_filter = Control.MOUSE_FILTER_STOP


func escurecer(duracao: float = DURACAO_PADRAO) -> void:
	# Bloqueia toques durante a transição
	_cortina.mouse_filter = Control.MOUSE_FILTER_STOP
	await _animar(1.0, duracao)


func clarear(duracao: float = DURACAO_PADRAO) -> void:
	await _animar(0.0, duracao)
	_cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _animar(alpha_final: float, duracao: float) -> void:
	var tween := create_tween()
	tween.tween_property(_cortina, "modulate:a", alpha_final, duracao)
	await tween.finished
