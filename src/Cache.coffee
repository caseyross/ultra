cache = {}

export CacheKey = (key, value) ->
	if cache[key]
		console.log('Cache hit: ' + key, cache[key])
		return cache[key]
	console.log('Cache miss: ' + key)
	return cache[key] = value
	

export CacheKeySave = (key, value) ->
	console.log('Cache save: ' + key)
	cache[key] = value
	return value