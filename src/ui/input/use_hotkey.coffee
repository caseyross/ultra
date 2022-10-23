handlers = {}

document.addEventListener('keydown', (e) ->
	if e.isTrusted and handlers[e.key]
		handlers[e.key]()
)

export default (element, char) ->
	if !char? then return null
	handlers[char] = -> element.dispatchEvent(new KeyboardEvent('keydown', { bubbles: true, code: 'Enter', key: 'Enter' }))
	return {
		destroy: -> delete handlers[char]
	}