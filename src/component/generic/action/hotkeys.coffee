handlers = {}

document.addEventListener('keydown', (e) ->
	switch
		when e.altKey
			return
		when e.ctrlKey
			return
		when e.metaKey
			return
		when e.shiftKey
			return
		else
			if e.isTrusted and handlers[e.key]?.length
				returnValue = handlers[e.key].at(-1)()
				if returnValue # handler can return false to allow default for event
					e.preventDefault()
)

export hotkey = (element, key) ->
	if !key? then return null
	if !handlers[key]
		handlers[key] = []
	handlers[key].push(-> element.dispatchEvent(new KeyboardEvent('keydown', { bubbles: true, code: 'Enter', key: 'Enter' })))
	return {
		destroy: -> handlers[key].pop() # potentially removes handlers out of order - if it becomes a problem we will change logic
	}

export virtual_hotkeys = (element, keymap) ->
	for key, handler of keymap
		if !handlers[key]
			handlers[key] = []
		handlers[key].push(handler)
	return {
		destroy: ->
			for key of keymap
				handlers[key].pop() # potentially removes handlers out of order - if it becomes a problem we will change logic
	}