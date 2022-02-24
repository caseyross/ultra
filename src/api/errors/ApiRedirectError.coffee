import ApiError from './ApiError.coffee'

export default class ApiRedirectError extends ApiError

	constructor: ({ code }) ->
		super("code #{code}")
		@.code = code