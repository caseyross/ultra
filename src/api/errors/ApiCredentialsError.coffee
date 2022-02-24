import ApiError from './ApiError.coffee'

export default class ApiCredentialsError extends ApiError

	constructor: ({ message }) ->
		super(message)