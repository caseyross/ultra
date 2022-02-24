import ApiError from './ApiError.coffee'

export default class ApiRequestError extends ApiError

	constructor: ({ code }) ->
		super("code #{code}")
		@.code = code