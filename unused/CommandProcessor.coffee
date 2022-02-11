export default class CommandProcessor extends EventTarget {

	constructor: (@commandMap, @state) ->

	# Note that events dispatched by process(), being synthetic events, are handled synchronously.
	# This is important when using these events to update external views of state, because it guarantees that you can run the view updates right after the state changes.
	process: (command) ->
		try
			stateChange = @commandMap(command.type)(command)
			if stateChange != null
				Object.assign(@state, stateChange)
			event = new Event('commandprocess')
			event.data = {
				command
				stateChange
			}
			@dispatchEvent(event)
			if stateChange != null
				event = new Event('statechange')
				event.data = stateChange
				@dispatchEvent(event)
		catch error
			event = new Event('commanderror')
			event.data = {
				command
				error
			}
			@dispatchEvent(event)

}