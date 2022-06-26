handlers = {}

document.addEventListener('keydown', (e) ->
	if handlers[e.key] then handlers[e.key](e)
)

export default (element, char) ->
	handlers[char] = (e) ->
		element.click()
	return {
		destroy: ->
			delete handlers[char]
	}