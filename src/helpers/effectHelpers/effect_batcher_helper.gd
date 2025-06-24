class_name EffectBatcherHelper

func create_batches(effects: Array):
	if effects.is_empty():
		return[]
	
	var groups = {}
	for effect in effects:
		var key = effect.effectName
		if !groups.has(key):
			groups[key] = []
		groups[key].append(effect)
	
	var batches = []
	for group in groups.values():
		batches.append(group)
		
	return batches

func calculate_total_time(batchCount: int, timePerBatch: float):
	return batchCount * timePerBatch
