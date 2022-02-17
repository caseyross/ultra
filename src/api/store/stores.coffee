class MergeOnlyStore

	constructor: ->
		@subscribers = new Map()
		@value = {}

	subscribe: (subscriber) ->
		subscriber(@value)
		subscriberId = Symbol()
		@subscribers.set(subscriberId, subscriber)
		-> @subscribers.delete(subscriberId)

	set: (additionalValue) ->
		Object.assign(@value, additionalValue)
		@subscribers.forEach (subscriber) -> subscriber(@value)


export class DownloadStore extends MergeOnlyStore

	constructor: ->
		super()

	add: (id) ->
		if !loading[id]
			loading[id] = true
			download(id)
				.then (data) ->
					{ main, other, fragments } = extract(data)
					data[id] = main
					fragment[id] = false
					for other of other
						status[subObject.id] = subObject.status
						data[subObject.id] = subObject.data
					for fragment of fragments
						fragment[id] = true
					@set(data)
					error[id] = false
				.catch (error) ->
					error[id] = error
				.finally ->
					loading[id] = false