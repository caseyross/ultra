import { getRatelimitStatus } from '../../../scripts/api/primitives/ratelimit.coffee'

export default
	6000: (state) ->
		return {
			...state
			ratelimitUsed: getRatelimitStatus().used
		}