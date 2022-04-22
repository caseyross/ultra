Math.clamp = (min, max, value) ->
	if value < min then return min
	if value > max then return max
	return value