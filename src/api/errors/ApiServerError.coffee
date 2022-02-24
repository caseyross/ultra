import ApiError from './ApiError.coffee'

export default class ApiServerError extends ApiError

	constructor: ({ code }) ->
		super("code #{code}")
		@.code = code