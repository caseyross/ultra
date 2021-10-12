if process.env.NODE_ENV is 'development'
	window.Log = window.console.log
	window.LogTable = window.console.table
	window.LogGroup = (title, messages) ->
		window.console.group(title)
		for message in messages
			window.console.log(message)
		window.console.groupEnd()
	window.Warn = window.console.warn
	# Error logging can just use the standard Error object. We don't want to log known errors anyway - fixing them is much preferable.
else
	window.Log = {}
	window.LogTable = {}
	window.LogGroup = {}
	window.Warn = {}

window.Storage = window.localStorage