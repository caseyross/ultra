handlers = {}

document.addEventListener('keydown', (e) ->
	if handlers[e.key] then handlers[e.key]()
)

export default (element, char) ->
	if !char? then return null
	handlers[char] = ->
		element.dispatchEvent(new MouseEvent('mousedown', { bubbles: true }))
		element.dispatchEvent(new MouseEvent('mouseup', { bubbles: true }))
	return {
		destroy: ->
			delete handlers[char]
	}