class_name PhaseConfig
extends Resource

@export_group("Jogo")
@export var velocidade_inicial: float = 200.0
@export var velocidade_maxima: float = 650.0
@export var tempo_ate_velocidade_maxima: float = 180.0

@export_group("Projéteis do Ovni")
@export var projetil_cena: PackedScene = preload("res://Features/Ovni/Projetil.tscn")
@export var projetil_textura: Texture2D
@export var velocidade_projetil_inicial: float = 401.0
@export var velocidade_projetil_maxima: float = 900.0
@export var intervalo_disparo: float = 1.0 
@export var intervalo_minimo: float = 0.4
@export var disparos_aceleram_com_dificuldade: bool = true

@export_group("Obstáculos")
@export var tem_pedra: bool = true
## Arte do obstáculo da fase (cacto, pedra...). Vazio mantém a da cena Pedra.
@export var textura_obstaculo: Texture2D
@export var tem_ovni: bool = true

@export_group("Barra / Objetivo")
enum ModoBarra { PROGRESSO_TEMPO, VIDA_OVNI }
@export var modo_barra: ModoBarra = ModoBarra.PROGRESSO_TEMPO
@export var tempo_fase: float = 60.0
@export var vida_ovni_max: int = 100
@export var energia_para_municao: int = 1

@export_group("Cenário")
@export var usar_transicao_cenario: bool = false
@export var lista_inicio: Array[PackedScene] = []
@export var lista_fim: Array[PackedScene] = []
@export var progresso_transicao: float = 0.5
