export default class CommandQueue extends EventTarget {

	constructor: ->

	add: (command) ->
		event = new Event('command')
		event.data = command
		@dispatchEvent(event)

}