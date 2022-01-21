export default class CommandQueue extends EventTarget {

	constructor: ->
		super()

	push: (command) ->
		event = new Event('command')
		event.data = command
		@dispatchEvent(event)

}