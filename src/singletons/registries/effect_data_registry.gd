extends Node

var effectDataById: Dictionary = {}

func _ready() -> void:
	if(EffectDictionaryJsonLoader.effectDictionaryData.is_empty()):
		await EffectDictionaryJsonLoader.ready
	
	for effectId in EffectDictionaryJsonLoader.effectDictionaryData.keys():
		var raw: Dictionary = EffectDictionaryJsonLoader.effectDictionaryData[effectId]
		var data: EffectData = EffectDataFactory.loadDictionary(effectId, raw)
		effectDataById[effectId] = data

func getEffectData(effectId: String) -> EffectData:
	if(!effectDataById.has(effectId)):
		push_error("EffectDataRegistry: unknown effect id %s" % effectId)
		return null
	return effectDataById[effectId]
