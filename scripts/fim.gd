extends Control

@onready var return_button: Button = $ReturnButton

func _ready() -> void:
	return_button.pressed.connect(voltar_ao_menu)

func voltar_ao_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
