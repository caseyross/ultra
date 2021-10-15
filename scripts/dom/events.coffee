export bubbleEvent = (event) ->
	event.target.dispatchEvent(new event.constructor('bubbling' + event.type, { ...event, bubbles: true }))