extends Control

@onready var play_button: Button = $PlayButton

func _ready() -> void:
	play_button.pressed.connect(iniciar_jogo)

func iniciar_jogo() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
