class_name BarraProgressaoMap
extends Control

# Sinal customizado para avisar o Core que o tempo acabou
signal stage_time_finished

# Tempo configurável pela aba Inspetor (240 segundos)
@export var total_stage_time: float = 30.0

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var timer: Timer = $Timer



func _ready() -> void:
	_setup_timer()
	_setup_progress_bar()

func _process(_delta: float) -> void:
	# Atualiza o valor visual da barra continuamente a cada frame
	if not timer.is_stopped():
		progress_bar.value = timer.time_left

func _setup_timer() -> void:
	timer.wait_time = total_stage_time
	timer.one_shot = true
	# Conecta o sinal nativo 'timeout' do nó Timer ao nosso método
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _setup_progress_bar() -> void:
	progress_bar.min_value = 0.0
	progress_bar.max_value = total_stage_time
	progress_bar.value = total_stage_time

func _on_timer_timeout() -> void:
	# Notifica quem estiver escutando (ex: o Core/GameManager)
	stage_time_finished.emit()


## Progresso da fase: 0.0 no início, 1.0 no fim.
func get_progresso() -> float:
	if total_stage_time <= 0.0:
		return 1.0
	return 1.0 - clampf(timer.time_left / total_stage_time, 0.0, 1.0)
