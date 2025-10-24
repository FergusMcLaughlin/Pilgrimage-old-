class_name EffectBaseClass
extends Resource

var data: EffectData

func should_trigger(event: String, source, context) -> bool:
	return false

func apply(source, context) -> void:
	pass
