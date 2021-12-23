import { getRatelimitStatus } from '../../../logic/net/ratelimit.coffee'

export default
	6000: (state) ->
		return {
			...state
			ratelimitUsed: getRatelimitStatus().used
		}