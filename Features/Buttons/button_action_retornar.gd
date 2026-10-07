extends Node

var isPaused: bool = false
@onready var menu_pause: Control = $menu_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	process_mode = Node.PROCESS_MODE_ALWAYS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
	
	
	
func _alternar_pausa() -> void:
	isPaused = !isPaused
	
	
	get_tree().paused = isPaused	
	menu_pause.visible = isPaused
