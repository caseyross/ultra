import { Time } from '../../utils/index.js'
import diagnostic from '../debug/diagnostic.coffee'
import ratelimit from '../network/ratelimit.coffee'
import ID from '../payload/ID.coffee'
import actionRoutes from '../payload/action/routes.coffee'
import datasetRoutes from '../payload/dataset/routes.coffee'
import datasetExtract from '../payload/dataset/extract.coffee'
import datasetExtractSpecial from '../payload/dataset/extractSpecial/index.js'
import errors from '../errors.coffee'

export load = (id) ->
	if not get(id)
		reload(id)
		return true
	else if get(id).loading
		return false
	else if get(id).partial
		reload(id)
		return true

export preload = (id) ->
	if ratelimit.availableRPS > Number(localStorage['api.config.preload_threshold'])
		load(id)
		return true
	return false

export reload = (id) ->
	route = datasetRoutes[ID.prefix(id)]
	if not route
		diagnostic({ id, error: new errors.BadIDError({ id }), message: "unknown dataset type" })
		return Promise.resolve(null)
	start = Time.epochMs()
	setLoading(id)
	return route(...ID.body(id))
	.then (rawData) ->
		extract = datasetExtractSpecial[ID.prefix(id)] ? datasetExtract
		extract(rawData, id)
	.then (datasets) ->
		diagnostic({ id, message: "#{Time.msToS(Time.epochMs() - start).toFixed(1)}s", details: datasets.main.data})
		setData(id, datasets.main.data, datasets.main.partial)
		for dataset in datasets.sub
			if not get(dataset.id) or get(dataset.id).partial == true or not dataset.partial
				setData(dataset.id, dataset.data, dataset.partial)
		return get(id)
	.catch (error) ->
		diagnostic({ id, error, message: "load failed" })
		setError(id, error)
		return get(id)

export send = (id) ->
	if get(id) and get(id).sending then return Promise.resolve(get(id))
	setSending(id)
	return actionRoutes[ID.prefix(id)](...ID.body(id))
	.then (rawFeedback) ->
		setFeedback(id, rawFeedback)
		return get(id)
	.catch (error) ->
		setError(id, error)
		return get(id)

cache = {}

export clear = ->
	cache = {}

export get = (id) ->
	if cache[id] then return cache[id]
	return null

export setData = (id, data, isPartial) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Time.epochMs()
	cache[id].data = data
	cache[id].error = false
	cache[id].loading = false
	cache[id].partial = isPartial ? false
	notify(id)

export setError = (id, error) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Time.epochMs()
	cache[id].data = null
	cache[id].error = error
	cache[id].feedback = null
	cache[id].loading = false
	cache[id].partial = false
	cache[id].sending = false
	notify(id)

export setFeedback = (id, feedback) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Time.epochMs()
	cache[id].error = false
	cache[id].feedback = feedback
	cache[id].sending = false
	notify(id)

export setLoading = (id) ->
	if !cache[id] then cache[id] = {}
	cache[id].loading = true
	notify(id)

export setSending = (id) ->
	if !cache[id] then cache[id] = {}
	cache[id].sending = true
	notify(id)

watchers = {}

notify = (id) ->
	if watchers[id]
		for callback in watchers[id] then callback(get(id))
		return watchers[id].length
	return 0
	
export watch = (id, callback, options = { autoload: true }) ->
	if !watchers[id] then watchers[id] = []
	watchers[id].push(callback)
	if get(id)
		callback(get(id))
	if options.autoload and get(id)?.partial != false
		load(id)
	return watchers[id].length