import ApiError from './ApiError.coffee'

export default class ApiRatelimitError extends ApiError

	constructor: ({ wait }) ->
		super("wait #{Date.asSeconds(wait)}")
		@.wait = wait