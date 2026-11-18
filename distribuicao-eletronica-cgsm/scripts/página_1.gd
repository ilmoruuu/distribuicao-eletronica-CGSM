
extends Node2D

@onready var oxygen_21: Sprite2D = $Node2D/Sprite2D2
@onready var oxigenio: Sprite2D = $Node2D/Sprite2D

@export var zoom_threshold: float = 1.8
@export var zoom_sensitivity: float = 0.005
@export var mouse_zoom_step: float = 0.15
@export var max_zoom: float = 3.0

var initial_scale: Vector2 = Vector2(0.39076793, 0.39076796)
var final_scale: Vector2 = Vector2(0.626, 0.626)

var touches: Dictionary = {}
var initial_distance: float = 0.0
var current_zoom: float = 1.0
var is_pinching: bool = false

var transition_started: bool = false
var tween: Tween


func _ready() -> void:
	oxygen_21.visible = true
	oxygen_21.scale = initial_scale
	oxygen_21.modulate.a = 1.0

	oxigenio.visible = false
	oxigenio.scale = Vector2.ZERO
	oxigenio.modulate.a = 0.0


func _input(event: InputEvent) -> void:
	if transition_started:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_zoom += mouse_zoom_step
			_apply_zoom()
			get_viewport().set_input_as_handled()

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_zoom -= mouse_zoom_step
			_apply_zoom()
			get_viewport().set_input_as_handled()

	elif event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)

		if touches.size() == 2:
			initial_distance = _get_finger_distance()
			is_pinching = true
		else:
			is_pinching = false
			initial_distance = 0.0

	elif event is InputEventScreenDrag:
		if touches.has(event.index):
			touches[event.index] = event.position

		if is_pinching and touches.size() == 2:
			_update_pinch_zoom()


func _apply_zoom() -> void:
	current_zoom = clampf(current_zoom, 1.0, max_zoom)

	oxygen_21.scale = initial_scale * current_zoom

	print("Zoom atual: ", current_zoom)

	if current_zoom >= zoom_threshold:
		_show_oxygen()


func _get_finger_distance() -> float:
	var positions = touches.values()

	if positions.size() < 2:
		return 0.0

	return positions[0].distance_to(positions[1])


func _update_pinch_zoom() -> void:
	var current_distance = _get_finger_distance()

	if initial_distance <= 0.0:
		return

	var distance_difference = current_distance - initial_distance

	current_zoom += distance_difference * zoom_sensitivity
	initial_distance = current_distance

	_apply_zoom()


func _show_oxygen() -> void:
	if transition_started:
		return

	transition_started = true
	is_pinching = false

	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		oxygen_21,
		"scale",
		initial_scale * max_zoom,
		0.8
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	tween.tween_property(
		oxygen_21,
		"modulate:a",
		0.0,
		0.8
	)

	oxigenio.visible = true
	oxigenio.scale = Vector2.ZERO
	oxigenio.modulate.a = 0.0

	tween.tween_property(
		oxigenio,
		"scale",
		final_scale,
		1.0
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		oxigenio,
		"modulate:a",
		1.0,
		0.8
	)

	tween.chain().tween_callback(
		func():
			oxygen_21.visible = false
	)
