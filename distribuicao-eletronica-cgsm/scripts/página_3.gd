extends Node2D

@onready var nucleo: Sprite2D = $Sprite2D2
@onready var eletrosfera: Sprite2D = $Sprite2D3
@onready var camadas: Sprite2D = $Sprite2D4

@export var distancia_arraste: float = 250.0
@export var intensidade_vibracao: float = 3.0
@export var velocidade_vibracao: float = 35.0

var posicao_original: Vector2
var arrastando := false
var interacao_concluida := false
var posicao_inicial_mouse: Vector2

var tween_vibracao: Tween


func _ready() -> void:
	posicao_original = nucleo.position

	eletrosfera.modulate.a = 0.0
	camadas.modulate.a = 0.0

	eletrosfera.visible = true
	camadas.visible = true

	iniciar_vibracao()


func _process(_delta: float) -> void:
	if interacao_concluida:
		return

	if arrastando:
		atualizar_arraste()


func iniciar_vibracao() -> void:
	if tween_vibracao and tween_vibracao.is_running():
		tween_vibracao.kill()

	tween_vibracao = create_tween()
	tween_vibracao.set_loops()

	tween_vibracao.tween_property(
		nucleo,
		"position",
		posicao_original + Vector2(intensidade_vibracao, 0),
		0.05
	).set_trans(Tween.TRANS_SINE)

	tween_vibracao.tween_property(
		nucleo,
		"position",
		posicao_original + Vector2(-intensidade_vibracao, 0),
		0.05
	).set_trans(Tween.TRANS_SINE)


func _input(event: InputEvent) -> void:
	if interacao_concluida:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			if nucleo.get_rect().has_point(
				nucleo.to_local(event.position)
			):
				arrastando = true
				posicao_inicial_mouse = event.position
		else:
			arrastando = false

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if nucleo.get_rect().has_point(
					nucleo.to_local(event.position)
				):
					arrastando = true
					posicao_inicial_mouse = event.position
			else:
				arrastando = false


func atualizar_arraste() -> void:
	var posicao_atual: Vector2 = get_global_mouse_position()

	var deslocamento: float = posicao_atual.x - posicao_inicial_mouse.x

	var progresso: float = clamp(
		deslocamento / distancia_arraste,
		0.0,
		1.0
	)

	eletrosfera.modulate.a = progresso
	camadas.modulate.a = progresso

	if progresso >= 1.0:
		finalizar_interacao()


func finalizar_interacao() -> void:
	interacao_concluida = true
	arrastando = false

	if tween_vibracao and tween_vibracao.is_running():
		tween_vibracao.kill()

	var tween := create_tween()

	tween.tween_property(
		nucleo,
		"position",
		posicao_original,
		0.2
	)

	tween.parallel().tween_property(
		eletrosfera,
		"modulate:a",
		1.0,
		0.3
	)

	tween.parallel().tween_property(
		camadas,
		"modulate:a",
		1.0,
		0.3
	)
