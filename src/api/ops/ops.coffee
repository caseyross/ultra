import { Time } from '../../lib/index.js'
import errors from '../base/errors.coffee'
import ID from '../base/ID.coffee'
import log from '../base/log.coffee'
import ratelimit from '../net/ratelimit.coffee'
import datasetExtractorGeneric from './dataset/extract.coffee'
import datasetExtractors from './dataset/extractors/index.js'
import datasetRoutes from './dataset/routes.coffee'
import datasetUpdaters from './dataset/updaters.coffee'
import interactionExtractors from './interaction/extractors/index.js'
import interactionPreupdaters from './interaction/preupdaters.coffee'
import interactionRoutes from './interaction/routes.coffee'
import interactionUpdaters from './interaction/updaters.coffee'

watchers = {}

notifyWatchers = (id) ->
	if watchers[id]
		for callback in watchers[id] then callback(cache[id])
		return watchers[id].length
	return 0
	
export watch = (id, callback) ->
	if !watchers[id] then watchers[id] = []
	watchers[id].push(callback)
	if cache[id] then callback(cache[id])
	return watchers[id].length

cache = {}

export clear = ->
	cache = {}
	watchers = {}

export load = (id) ->
	if not cache[id]
		reload(id)
		return true
	else if cache[id].loading
		return false
	else if cache[id].error or cache[id].partial
		reload(id)
		return true
	else
		return false

export loadWatch = (id, callback) ->
	load(id)
	watch(id, callback)

export preload = (id) ->
	if ratelimit.availableRPS > Number(localStorage['api.config.preload_threshold'])
		load(id)
		return true
	return false

export reload = (id) ->
	route = datasetRoutes[ID.type(id)]
	if not route
		log({
			id,
			error: new errors.MalformedID({ id }),
			message: "unknown dataset type",
		})
		return Promise.resolve(null)
	startTime = Time.unixMs()
	setLoading(id)
	return route(...ID.varArray(id)[1..])
	.then (rawData) ->
		extract = datasetExtractors[ID.type(id)] ? datasetExtractorGeneric
		extract(rawData, id)
	.then (datasets) ->
		log({
			id,
			details: datasets.main.data,
			message: "#{Time.msToS(Time.unixMs() - startTime).toFixed(1)}s",
		})
		for dataset in datasets.sub
			if !cache[dataset.id] or (cache[dataset.id].partial is true) or !dataset.partial
				setData(dataset.id, dataset.data, dataset.partial, dataset.merge)
		setData(id, datasets.main.data, datasets.main.partial, datasets.main.merge)
		updater = datasetUpdaters[ID.type(id)]
		if updater
			targetID = updater.targetID(...ID.varArray(id)[1..])
			if targetID
				change = (target) -> updater.modify(target, datasets.main.data)
				setDataFromExisting(targetID, change)
	.catch (error) ->
		log({
			id,
			error,
			message: "load failed",
		})
		setError(id, error)
	.finally ->
		return cache[id]

setData = (id, data, partial = false, merge = false) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Time.unixMs()
	# For most datasets, we will simply overwrite the entire object. However, certain datasets (e.g. comments from differing endpoints) need to be handled with more scrutiny, as they may not represent straight sub- or super-sets of the same object.
	if cache[id].data and merge
		for newKey, newValue of data
			# Write or overwrite keys where the new value is non-trivial, except don't overwrite existing arrays of greater length.
			unless !newValue? or (Array.isArray(cache[id].data[newKey]) and Array.isArray(newValue) and cache[id].data[newKey].length > newValue.length)
				cache[id].data[newKey] = newValue
	else
		cache[id].data = data
	cache[id].error = false
	cache[id].loading = false
	cache[id].partial = partial
	notifyWatchers(id)

setDataFromExisting = (id, change) ->
	rollback = change(cache[id].data)
	notifyWatchers(id)
	return rollback

setError = (id, error) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Time.unixMs()
	cache[id].data = null
	cache[id].error = error
	cache[id].loading = false
	cache[id].partial = false
	notifyWatchers(id)

setLoading = (id) ->
	if !cache[id] then cache[id] = {}
	cache[id].asOf = Time.unixMs()
	cache[id].loading = true
	notifyWatchers(id)

export submit = (id, payload, reportStatus = ->) ->
	route = interactionRoutes[ID.type(id)]
	if not route
		log({
			id,
			error: new errors.MalformedID({ id }),
			message: "unknown interaction type",
		})
		return Promise.resolve(null)
	startTime = Time.unixMs()
	reportStatus({ error: null, sending: true, success: false })
	preupdater = interactionPreupdaters[ID.type(id)]
	if preupdater
		targetID = preupdater.targetID(...ID.varArray(id)[1..])
		change = (target) -> preupdater.modify(target, payload)
		rollback = setDataFromExisting(targetID, change)
	return route(...ID.varArray(id)[1..])(payload)
	.then (rawData) ->
		error = rawData?.json?.errors?[0]
		if error
			switch error?[0]
				when 'USER_REQUIRED'
					throw new errors.NotLoggedIn()
				else
					throw new errors.InteractionRejected({
						code: error?[0]
						description: error?[1]
					})
		response = rawData?.json?.data or rawData
		log({
			id,
			details: { payload, response },
			message: "#{Time.msToS(Time.unixMs() - startTime).toFixed(1)}s",
		})
		extract = interactionExtractors[ID.type(id)]
		if extract
			datasets = extract(response)
			for dataset in datasets.sub
				if !cache[dataset.id] or (cache[dataset.id].partial is true) or !dataset.partial
					setData(dataset.id, dataset.data, dataset.partial, dataset.merge)
			if datasets.main.id
				setData(datasets.main.id, datasets.main.data, datasets.main.partial, datasets.main.merge)
				updater = interactionUpdaters[ID.type(id)]
				if updater
					targetID = updater.targetID(...ID.varArray(id)[1..])
					if targetID
						change = (target) -> updater.modify(target, datasets.main.data)
						setDataFromExisting(targetID, change)
		reportStatus({ error: null, sending: false, success: true })
	.catch (error) ->
		reportStatus({ error, sending: false, success: false })
		log({
			id,
			details: { payload },
			error,
			message: "send failed",
		})
		if rollback
			setDataFromExisting(targetID, rollback)