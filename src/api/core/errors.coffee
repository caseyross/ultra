export class ApiError extends Error

	TYPE_CONNECTION = Symbol()
	TYPE_CREDENTIALS = Symbol()
	TYPE_OTHER = Symbol()
	TYPE_RATELIMIT = Symbol()
	TYPE_REQUEST = Symbol()
	TYPE_RESOURCE = Symbol()
	TYPE_SERVER = Symbol()

	constructor: (...params) ->
		super(...params)
		@name = 'ApiError'