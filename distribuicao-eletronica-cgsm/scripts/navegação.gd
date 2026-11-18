
extends Control

const PAGINAS: Array[String] = [
	"res://scenes/Capa.tscn",
	"res://scenes/Página1.tscn",
	"res://scenes/Referências.tscn",
	"res://scenes/Contracapa.tscn"
]

func _ready() -> void:
	var cena_atual := get_tree().current_scene.scene_file_path.get_file()

	if cena_atual == "Capa.tscn":
		$Button.pressed.connect(proxima_pagina)

	elif cena_atual == "Contracapa.tscn":
		$Button.pressed.connect(voltar_inicio)
		$Button2.pressed.connect(pagina_anterior)

	else:
		$Button.pressed.connect(proxima_pagina)
		$Button2.pressed.connect(pagina_anterior)


func proxima_pagina() -> void:
	var indice := _obter_indice_atual()

	if indice >= 0 and indice < PAGINAS.size() - 1:
		_carregar_pagina(indice + 1)


func pagina_anterior() -> void:
	var indice := _obter_indice_atual()

	if indice > 0:
		_carregar_pagina(indice - 1)


func voltar_inicio() -> void:
	_carregar_pagina(0)


func _obter_indice_atual() -> int:
	var caminho_atual := get_tree().current_scene.scene_file_path

	return PAGINAS.find(caminho_atual)


func _carregar_pagina(indice: int) -> void:
	var resultado := get_tree().change_scene_to_file(PAGINAS[indice])

	if resultado != OK:
		push_error("Não foi possível carregar a página: " + PAGINAS[indice])
