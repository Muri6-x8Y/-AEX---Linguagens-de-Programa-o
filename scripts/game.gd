extends Control

@onready var phase_label: Label = $PhaseLabel
@onready var instruction_label: Label = $InstructionLabel
@onready var feedback_label: Label = $FeedbackLabel
@onready var tank_container: HBoxContainer = $TankContainer

@onready var botoes: Array[Button] = [
	$OptionsContainer/Option1,
	$OptionsContainer/Option2,
	$OptionsContainer/Option3
]


var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var fase_atual: int = 0

var total: int = 0
var quantidade_atual: int = 0
var quantidade_restante: int = 0

var valores_dos_galoes: Array[int] = []

const FASES: Array[Dictionary] = [
	{
		"total_min": 4,
		"total_max": 5,
		"falta_min": 2,
		"falta_max": 3,
		"tipo": "numero"
	},
	{
		"total_min": 6,
		"total_max": 7,
		"falta_min": 2,
		"falta_max": 4,
		"tipo": "numero"
	},
	{
		"total_min": 7,
		"total_max": 8,
		"falta_min": 2,
		"falta_max": 4,
		"tipo": "adicao"
	},
	{
		"total_min": 8,
		"total_max": 9,
		"falta_min": 3,
		"falta_max": 5,
		"tipo": "adicao"
	},
	{
		"total_min": 9,
		"total_max": 10,
		"falta_min": 4,
		"falta_max": 6,
		"tipo": "misto"
	}
]


func _ready() -> void:
	rng.randomize()

	conectar_botoes()
	iniciar_fase()


func conectar_botoes() -> void:
	for indice in range(botoes.size()):
		botoes[indice].pressed.connect(
			clicar_no_galao.bind(indice)
		)


func iniciar_fase() -> void:
	feedback_label.text = ""

	for botao in botoes:
		botao.disabled = false
		botao.visible = true

	gerar_desafio()
	atualizar_interface()


func gerar_desafio() -> void:
	var configuracao: Dictionary = FASES[fase_atual]

	total = rng.randi_range(
		configuracao["total_min"],
		configuracao["total_max"]
	)

	var falta_maxima: int = min(
		configuracao["falta_max"],
		total - 1
	)

	quantidade_restante = rng.randi_range(
		configuracao["falta_min"],
		falta_maxima
	)

	quantidade_atual = total - quantidade_restante

	gerar_alternativas()


func gerar_alternativas() -> void:
	valores_dos_galoes = [
		quantidade_restante - 1,
		quantidade_restante,
		quantidade_restante + 1
	]

	valores_dos_galoes.shuffle()


func atualizar_interface() -> void:
	phase_label.text = "Fase %d de %d" % [
		fase_atual + 1,
		FASES.size()
	]

	instruction_label.text = (
		"O tanque precisa chegar a %d.\n"
		+ "Já temos %d. Qual galão completa\n o tanque?"
	) % [
		total,
		quantidade_atual
	]

	for indice in range(botoes.size()):
		var valor: int = valores_dos_galoes[indice]
		botoes[indice].text = criar_texto_do_galao(valor)

	atualizar_tanque()


func criar_texto_do_galao(valor: int) -> String:
	var tipo: String = FASES[fase_atual]["tipo"]

	if tipo == "numero":
		return str(valor)

	if tipo == "adicao":
		return criar_adicao(valor)

	if tipo == "misto":
		var usar_adicao: bool = rng.randi_range(0, 1) == 0

		if usar_adicao:
			return criar_adicao(valor)
		else:
			return criar_subtracao(valor)

	return str(valor)


func criar_adicao(resultado: int) -> String:
	var primeiro: int = rng.randi_range(1, resultado - 1)
	var segundo: int = resultado - primeiro

	return "%d + %d" % [primeiro, segundo]


func criar_subtracao(resultado: int) -> String:
	var segundo: int = rng.randi_range(1, 3)
	var primeiro: int = resultado + segundo

	return "%d - %d" % [primeiro, segundo]


func clicar_no_galao(indice: int) -> void:
	var valor_escolhido: int = valores_dos_galoes[indice]

	verificar_resposta(valor_escolhido)


func verificar_resposta(valor_do_galao: int) -> void:
	if valor_do_galao == quantidade_restante:
		resposta_correta()
	else:
		feedback_label.text = (
			"Observe quanto 
			falta no tanque!"
		)


func resposta_correta() -> void:
	feedback_label.text = (
		"Muito bem!"
		% quantidade_restante
	)

	quantidade_atual = total
	atualizar_tanque()

	for botao in botoes:
		botao.disabled = true

	await get_tree().create_timer(1.5).timeout

	fase_atual += 1

	if fase_atual < FASES.size():
		iniciar_fase()
	else:
		finalizar_jogo()


func atualizar_tanque() -> void:
	var espacos: Array[Node] = tank_container.get_children()

	for indice in range(espacos.size()):
		var espaco: ColorRect = espacos[indice] as ColorRect

		espaco.visible = indice < total

		if not espaco.visible:
			continue

		if indice < quantidade_atual:
			espaco.color = Color(0.4, 0.8, 0.2)
		else:
			espaco.color = Color(0.517, 0.517, 0.517, 1.0)


func finalizar_jogo() -> void:
	get_tree().change_scene_to_file("res://scenes/fim.tscn")
