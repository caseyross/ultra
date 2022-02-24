import ApiError from './ApiError.coffee'

export default class ApiOtherError extends ApiError

	constructor: ({ cause }) ->
		super(cause.message)