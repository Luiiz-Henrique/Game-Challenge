class_name BarraProgressaoMap
extends Control

# Sinal customizado para avisar o Core que o tempo acabou
signal stage_time_finished

# Tempo configurável pela aba Inspetor (240 segundos)
@export var total_stage_time: float = 10.0
@onready var icone: TextureRect = $ProgressBar/IconeBar
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var timer: Timer = $Timer

func _atualizar_icone() -> void:
	var ratio := progress_bar.value / progress_bar.max_value
	var tamanho_icone := icone.size * icone.scale
	icone.position.x = progress_bar.size.x * ratio - tamanho_icone.x / 2.0

func _ready() -> void:
	_setup_timer()
	_setup_progress_bar()
	_atualizar_icone()

func _process(_delta: float) -> void:
	# Atualiza o valor visual da barra continuamente a cada frame
	if not timer.is_stopped():
		progress_bar.value = get_progresso()
		_atualizar_icone()

func _setup_timer() -> void:
	timer.wait_time = total_stage_time
	timer.one_shot = true
	# Conecta o sinal nativo 'timeout' do nó Timer ao nosso método
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

## Redefine a duração da fase e reinicia a contagem (call down do GameContext).
func configurar_tempo(segundos: float) -> void:
	total_stage_time = segundos
	timer.wait_time = total_stage_time
	timer.start()
	progress_bar.value = 0
	_atualizar_icone()

func _setup_progress_bar() -> void:
	progress_bar.min_value = 0.0
	progress_bar.max_value = 1
	progress_bar.step = 0.0
	progress_bar.value = 0

func _on_timer_timeout() -> void:
	# Notifica quem estiver escutando (ex: o Core/GameManager)
	progress_bar.value = progress_bar.max_value
	stage_time_finished.emit()
	_atualizar_icone()

## Progresso da fase: 0.0 no início, 1.0 no fim.
func get_progresso() -> float:
	if total_stage_time <= 0.0:
		return 1.0
	return 1.0 - clampf(timer.time_left / total_stage_time, 0.0, 1.0)
