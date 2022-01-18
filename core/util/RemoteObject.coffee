export default class RemoteObject

	constructor: (object) ->
		@data = object
		@vintage = Date.now()