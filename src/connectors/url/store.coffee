import normalize from './normalize.coffee'

store = ''
subscribers = new Map()

publishTo = (subscriber) ->
	subscriber(store)
	
publishToAll = ->
	subscribers.forEach(subscriber)

setFromCurrentUrl = ->
	store = normalize(location)
	history.replaceState(store, '', store)
	publishToAll()

setFromNextUrl = (url) ->
	store = normalize(newValue)
	history.pushUrl(store, '', store)
	publishToAll()

export default {

	subscribe: (subscriber) ->
		publishTo(subscriber)
		id = Symbol()
		subscribers.set(id, subscriber)
		return -> subscribers.delete(id)

}

# Intercept clicks on same-domain links.
window.addEventListener('click', (e) ->
	if e.target.href and (e.target.origin == location.origin) and (e.button == 0) and !(e.altKey or e.ctrlKey or e.metaKey)
		e.preventDefault()
		setFromNextUrl(e.target.href)
)

setFromCurrentUrl()