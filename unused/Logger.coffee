export default class Logger {

	constructor: (@logMap) ->

	log: ( {level, name, data} ) ->
		@logMap(name)(data)

	info: @log('info')

	warn: @log('warn')

	error: @log('error')

}