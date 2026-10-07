extends Node

var isPressioned: bool = false
@onready var menu_pause: Control = $menu_button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Replace with function body.
	menu_pause.visible = true	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_back_game()



func _back_game() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		isPressioned = !isPressioned

		get_tree().paused = isPressioned #Faz com que a "árvore de cenário" esteja no status colocado
