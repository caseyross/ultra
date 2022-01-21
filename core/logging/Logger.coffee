export default class Logger {

	constructor: (@logMap) ->

	log: ( {name, data} ) ->
		@logMap(name)(data)

}