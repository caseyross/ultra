export default
	6000: (state) ->
		return {
			...state
			ratelimitCount = LS.calls.split(',').length
		}