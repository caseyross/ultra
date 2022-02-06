export default class ApiError extends Error

	static TYPE_CONNECTION = Symbol()
	static TYPE_CREDENTIALS = Symbol()
	static TYPE_OTHER = Symbol()
	static TYPE_RATELIMIT = Symbol()
	static TYPE_REQUEST = Symbol()
	static TYPE_RESOURCE = Symbol()
	static TYPE_SERVER = Symbol()

	constructor: (...params) ->
		super(...params)
		@name = 'ApiError'