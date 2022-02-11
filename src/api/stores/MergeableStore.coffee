export default class MergeableStore

	constructor: ->
		@subscribers = new Map()
		@value = {}

	subscribe: (subscriber) ->
		subscriber(@value)
		subscriberId = Symbol()
		@subscribers.set(subscriberId, subscriber)
		-> @subscribers.delete(subscriberId)

	set: (newValue) ->
		@value = newValue
		@subscribers.forEach (subscriber) -> subscriber(@value)

	merge: (additionalValue) ->
		@set(Object.assign(@value, additionalValue))