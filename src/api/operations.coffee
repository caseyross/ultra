import { Time } from '../utils/index.js'
import ratelimit from './infra/ratelimit.coffee'
import parse from './infra/parse.coffee'
import actionRoutes from './actions/routes.coffee'
import datasetRoutes from './datasets/routes.coffee'
import datasetGeneralExtractor from './datasets/extractors/general/extract.coffee'
import datasetSpecialExtractor from './datasets/extractors/special/extract.coffee'

cache = {}

export deleteCachedData = ->
	cache = {}

get = (id) ->
	if cache[id] then return cache[id]
	return null

setData = (id, data, isPartial) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Time.epochMs()
	cache[id].data = data
	cache[id].error = false
	cache[id].loading = false
	cache[id].partial = isPartial ? false
	notify(id)

setError = (id, error) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Time.epochMs()
	cache[id].data = null
	cache[id].error = error
	cache[id].feedback = null
	cache[id].loading = false
	cache[id].partial = false
	cache[id].sending = false
	notify(id)

setFeedback = (id, feedback) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Time.epochMs()
	cache[id].error = false
	cache[id].feedback = feedback
	cache[id].sending = false
	notify(id)

setLoading = (id) ->
	if !cache[id] then cache[id] = {}
	cache[id].loading = true
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
	if ratelimit.availableRPS > 0.5
		load(id)
		return true
	return false

export reload = (id) ->
	setLoading(id)
	return datasetRoutes[parse.datasetType(id)](...parse.datasetFilters(id))
	.then (rawData) ->
		extractor = datasetSpecialExtractor[parse.datasetType(id)] ? datasetGeneralExtractor
		extractor(rawData)
	.then (datasets) ->
		setData(id, datasets.main.data, datasets.main.partial)
		for dataset in datasets.sub
			if not get(dataset.id) or get(dataset.id).partial == true or not dataset.partial
				setData(dataset.id, dataset.data, dataset.partial)
		return get(id)
	.catch (error) ->
		setError(id, error)
		return get(id)

export send = (id) ->
	if get(id) and get(id).sending then return Promise.resolve(get(id))
	setSending(id)
	return actionRoutes[parse.actionType(id)](...parse.actionParameters(id))
	.then (rawFeedback) ->
		setFeedback(id, rawFeedback)
		return get(id)
	.catch (error) ->
		setError(id, error)
		return get(id)

export watch = (id, callback, options = { autoload: true }) ->
	if !watchers[id] then watchers[id] = []
	watchers[id].push(callback)
	if get(id)
		callback(get(id))
	if options.autoload and (!get(id) or get(id).partial)
		load(id)
	return watchers[id].length