## MADE BY AHMED GD!!
@icon("res://Components/IconGodotNode/node/icon_crate.png")
class_name TweenerComponent extends Node

@export var curves: Dictionary[String, Curve]

@export var transition_type: Tween.TransitionType
@export var ease_type: Tween.EaseType

func play_tween(object: Variant, method: String, values: Array, durations: Array[float], trans: Tween.TransitionType = transition_type, tween_ease: Tween.EaseType = ease_type, loop: bool = false) -> void:
	while true:
		if values.size() != durations.size():
			push_error("The sizes of these two arrays must be equally")
			return
		
		var tween: Tween = create_tween()
		tween = tween.set_trans(trans).set_ease(tween_ease)
		
		for i: int in values.size():
			tween.tween_property(object, method, values[i], durations[i])
		
		await tween.finished
		
		if !loop:
			break

func play_curve(object: Variant, method: String, curve_name: String, initial_value: Variant, final_value: Variant, duration: float = 1.0, delay: float = 0.0, loop: bool = false) -> void:
	while true:
		var tween: Tween = create_tween()
		tween.tween_method(interpolate.bind(object, method, curves[curve_name], initial_value, final_value), 0.0, 1.0, duration).set_delay(delay)
		
		if !loop:
			break

func interpolate(new_value: Variant, object: Variant, property: String, curve: Curve, a: Variant, b: Variant) -> void:
	object.set(property, a + ((b - a) * curve.sample(new_value)))
