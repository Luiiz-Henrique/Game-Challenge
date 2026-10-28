class_name ContadorPedacos
extends HBoxContainer

## Contador de pedaços do dispositivo exibido no mapa ("N/3").
## A arma montada fica escurecida até o jogador juntar todos os pedaços.

const COR_INCOMPLETA := Color(0.25, 0.25, 0.3)
const COR_COMPLETA := Color.WHITE

@onready var arma: TextureRect = $Arma
@onready var contagem: Label = $Contagem


func _ready() -> void:
	atualizar()


func atualizar() -> void:
	contagem.text = "%d/%d" % [PedacosDispositivo.quantidade(), PedacosDispositivo.TOTAL]
	arma.modulate = COR_COMPLETA if PedacosDispositivo.esta_completo() else COR_INCOMPLETA
