import routes from './routes.coffee'
import extractGeneral from './extractors/general.coffee'
import extractSpecial from './extractors/special/index.coffee'

store = {}
subscribers = new Map()

publishTo = (subscriber) ->
	subscriber(store)

publishToAll = ->
	console.table store
	for subscriber in subscribers
		publishTo(subscriber)

setLoading = (id) ->
	store[id] = {
		loading: true
	}

setError = (id, error) ->
	store[id] = {
		loading: false
		error: error
	}

setData = (id, data, partial) ->
	store[id] = {
		loading: false
		error: false
		partial: partial ? false
		data: data
		asOf: Date.now()
	}

export default {

	load: (id) ->
		setLoading(id)
		publishToAll()
		request = routes[id.idType] ? Promise.reject()
		request(...id.idSpecs)
			.then((rawData) ->
				extract = extractSpecial[id.idType] ? extractGeneral
				extract(rawData)
			)
			.catch((error) ->
				setError(id, error)
				publishToAll()
				throw error
			)
			.then(({ main, sub }) ->
				setData(id, main.data, main.partial)
				for object in sub
					setData(object.id, object.data, object.partial)
				publishToAll()
				return main.data
			)

	subscribe: (subscriber) ->
		publishTo(subscriber)
		id = Symbol()
		subscribers.set(id, subscriber)
		return -> subscribers.delete(id)

}