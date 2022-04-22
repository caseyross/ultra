import actionRoutes from './actions/routes.coffee'
import datasetRoutes from './datasets/routes.coffee'
import datasetGeneralExtractor from './datasets/extractors/general/extract.coffee'
import datasetSpecialExtractor from './datasets/extractors/special/extract.coffee'

cache = {}

get = (id) ->
	if cache[id] then return cache[id]
	return null

setData = (id, data, isPartial) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Date.now()
	cache[id].data = data
	cache[id].error = false
	cache[id].loading = false
	cache[id].partial = isPartial ? false
	cache[id].sending = false
	notify(id)

setError = (id, error) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Date.now()
	cache[id].data = null
	cache[id].error = error
	cache[id].loading = false
	cache[id].partial = false
	cache[id].sending = false
	notify(id)

setLoading = (id) ->
	if !cache[id] then cache[id] = {}
	cache[id].loading = false
	notify(id)

setSending = (id) ->
	if !cache[id] then cache[id] = {}
	cache[id].sending = true
	notify(id)

watchers = {}

notify = (id) ->
	if watchers[id]
		for callback in watchers[id] then callback(get(id))
		return watchers[id].length
	return 0

export load = (id) ->
	if get(id) and get(id).partial == false then return Promise.resolve(get(id))
	return reload(id)

export preload = (id) ->
	if true # TODO
		return load(id)
	return Promise.resolve(false)

export reload = (id) ->
	setLoading(id)
	return datasetRoutes[id.idType](...id.idSpecs)
	.then (rawData) ->
		extractor = datasetSpecialExtractor[id.idType] ? datasetGeneralExtractor
		extractor(rawData)
	.then (datasets) ->
		setData(id, datasets.main.data, datasets.main.partial)
		for dataset in datasets.sub then setData(dataset.id, dataset.data, dataset.partial)
	.catch (error) ->
		setError(id, error)
	.finally ->
		return get(id)

export send = (id) ->
	setSending(id)
	# TODO

export watch = (id, callback) ->
	if !watchers[id] then watchers[id] = []
	watchers[id].push(callback)
	if get(id)
		if get(id).partial then load(id)
		callback(get(id))
	else
		load(id)
	return watchers[id].length