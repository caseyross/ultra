export default {
	'Command Successfully Processed': (data) ->
		console.group 'Processed command: "' + data.command.name + '"'
		console.log 'State modification was:'
		console.log data.stateChange
		console.groupEnd()
	'Error While Processing Command': (data) ->
		console.group 'Failed to process command: "' + data.command.name + '"'
		console.log 'Data was:'
		console.log data.command.data
		console.log 'Error was:'
		console.log data.error
		console.groupEnd()
}