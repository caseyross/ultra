export default class RateLimitError extends Error
	constructor: (message) ->
		super(message)
		@name = 'RateLimitError'