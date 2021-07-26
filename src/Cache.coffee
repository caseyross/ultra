cache = {}

export cached = (key, func) ->
	if cache[key]
		console.log('Cache hit: ' + key, cache[key])
		return cache[key]
	console.log('Cache miss: ' + key)
	return cache[key] = func()