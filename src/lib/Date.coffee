Object.defineProperty(Date, 'age', {
	get: ->
		Date.now() - @valueOf()
})

Date.describeDuration = (duration) ->
	s = duration / 1000
	if s < 60
		return
			count: Math.trunc(s)
			unit: 's'
	m = s / 60
	if m < 60
		return
			count: Math.trunc(m)
			unit: 'm'
	h = m / 60
	if h < 24
		return
			count: Math.trunc(h)
			unit: 'h'
	d = h / 24
	if d < 7
		return
			count: Math.trunc(d)
			unit: 'd'
	wk = d / 7
	if wk < 4
		return
			count: Math.trunc(wk)
			unit: 'w'
	mo = d / 28
	if mo < 12
		return
			count: Math.trunc(mo)
			unit: 'mo'
	yr = mo / 12
	return
		count: Math.trunc(yr)
		unit: 'yr'


Date.seconds = (numSeconds) ->
	1000 * numSeconds
Date.minutes = (numMinutes) ->
	1000 * 60 * numMinutes
Date.hours = (numHours) ->
	1000 * 60 * 60 * numHours