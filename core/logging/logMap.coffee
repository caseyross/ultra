export default {
	'Command Successfully Processed': (data) ->
		console.group 'Command processed: "' + data.command.type + '"'
		console.log 'State change:'
		console.log data.stateChange
		console.groupEnd()
	'Error While Processing Command': (data) ->
		console.group 'Command failed: "' + data.command.type + '"'
		console.log 'Error:'
		console.log data.error
		console.log 'Data:'
		console.log data.command
		console.groupEnd()
}