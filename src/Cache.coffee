cache = {}

export cached = (key, value) ->
	if cache[key]
		console.log('Cache hit: ' + key, cache[key])
		return cache[key]
	console.log('Cache miss: ' + key)
	return cache[key] = value