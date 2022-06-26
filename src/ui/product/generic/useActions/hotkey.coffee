handlers = {}

document.addEventListener('keydown', (e) ->
	if handlers[e.key] then handlers[e.key]()
)

export default (element, char) ->
	if !char? then return null
	handlers[char] = ->
		element.dispatchEvent(new Event('mousedown'))
		element.dispatchEvent(new Event('mouseup'))
		element.dispatchEvent(new Event('click'))
	return {
		destroy: ->
			delete handlers[char]
	}