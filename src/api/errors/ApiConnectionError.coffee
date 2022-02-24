import ApiError from './ApiError.coffee'

export default class ApiConnectionError extends ApiError

	constructor: ({ cause }) ->
		super(cause.message)