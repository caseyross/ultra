months = [
	{ short_name: 'Jan' }
	{ short_name: 'Feb' }
	{ short_name: 'Mar' }
	{ short_name: 'Apr' }
	{ short_name: 'May' }
	{ short_name: 'Jun' }
	{ short_name: 'Jul' }
	{ short_name: 'Aug' }
	{ short_name: 'Sep' }
	{ short_name: 'Oct' }
	{ short_name: 'Nov' }
	{ short_name: 'Dec' }
]

units =
	year:
		abbr: 'y'
		name: 'year'
		value: 1000 * 60 * 60 * 24 * 366
	month:
		abbr: 'mo'
		name: 'month'
		value: 1000 * 60 * 60 * 24 * 31
	week:
		abbr: 'w'
		name: 'week'
		value: 1000 * 60 * 60 * 24 * 7
	day:
		abbr: 'd'
		name: 'day'
		value: 1000 * 60 * 60 * 24
	hour:
		abbr: 'h'
		name: 'hour'
		value: 1000 * 60 * 60
	minute:
		abbr: 'm'
		name: 'minute'
		value: 1000 * 60
	second:
		abbr: 's'
		name: 'second'
		value: 1000
	millisecond:
		abbr: 'ms'
		name: 'millisecond'
		value: 1

Time = {

	unixMs: -> Date.now()
	
	hToMs: (h) -> units.hour.value * h
	mToMs: (m) -> units.minute.value * m
	sToMs: (s) -> units.second.value * s

	msToH: (ms, opt = { trunc: false }) ->
		h = ms / units.hour.value
		if opt.trunc
			return Math.trunc(h)
		else
			return h
	msToM: (ms, opt = { trunc: false }) ->
		m = ms / units.minute.value
		if opt.trunc
			return Math.trunc(m)
		else
			return m
	msToS: (ms, opt = { trunc: false }) ->
		s = ms / units.second.value
		if opt.trunc
			return Math.trunc(s)
		else
			return s

	msToAge: (ms) ->
		nowMs = Time.unixMs()
		result = []
		for id, unit of units
			result[unit.name + 's'] = Math.trunc((nowMs - ms) / unit.value)
		return result

	msToTopDuration: (ms, opt = { trunc: true }) ->
		for id, unit of units
			if ms > unit.value
				count = ms / unit.value
				return {
					count: if opt.trunc then Math.trunc(count) else count,
					unit
				}
		return {
			count: 0
			unit: units.millisecond
		}
	
	msToMediaDurationStr: (ms) ->
		s = Time.msToS(ms, { trunc: true })
		m = 0
		while s >= 60
			s = s - 60
			m = m + 1
		return "#{String(m).padStart(2, '0')}:#{String(s).padStart(2, '0')}"

	msToAbsTimeStr: (ms) ->
		date = new Date(ms)
		return "#{date.getFullYear()}-#{String(date.getMonth() + 1).padStart(2, '0')}-#{String(date.getDate()).padStart(2, '0')} #{String(date.getHours()).padStart(2, '0')}:#{String(date.getMinutes()).padStart(2, '0')}"
	
	msToAbsRelTimeStr: (ms) ->
		# We want to account for day boundaries when counting relative days - i.e. treat days as midnight--midnight rather than just a particular number of milliseconds.
		# The key thing to note is that because the naive duration is "floored" to an integer, there is a discontinuity at precisely the hours, minutes, and seconds value at which the naive duration was calculated.
		# The effect of this is that past times later in the day than the calculation time are counted as 1 less day than we would expect, based on day boundaries.
		#
		#  MIDNIGHT  * -------------------------------------------------------------- 
		#           / 
		#          /    [ PAST HH:MM:SS EARLIER THAN CURRENT (CORRECT NAIVE DAY COUNT) ] 
		#         /
		#        / < HH:MM:SS FOR NAIVE CALCULATION
		#       /
		#      /    [ PAST HH:MM:SS LATER THAN CURRENT (NAIVE DAY COUNT OFF BY -1) ]
		#     /
		#    * NEXT DAY -------------------------------------------------------------
		#
		daysBack = 'MANY'
		targetDate = new Date(ms)
		currentDate = new Date()
		duration = Time.msToTopDuration(Time.unixMs() - ms, { trunc: true })
		switch duration.unit.name
			when 'day'
				HHMMSS = (date) ->
					[date.getHours(), date.getMinutes(), date.getSeconds()].map((s) -> String(s).padStart(2, '0')).join(':')
				daysBack = if HHMMSS(currentDate) > HHMMSS(targetDate) then duration.count else duration.count + 1 # string comparison
			when 'hour'
				daysBack = if duration.count > currentDate.getHours() then 1 else 0
			when 'minute'
				daysBack = if currentDate.getHours() is 0 and duration.count > currentDate.getMinutes() then 1 else 0
			when 'second'
				daysBack = if currentDate.getHours() is 0 and currentDate.getMinutes() is 0 and duration.count > currentDate.getSeconds() then 1 else 0
			when 'millisecond'
				daysBack = 0
		if duration.count < 0
			daysBack = 0
		switch
			when daysBack < 1
				targetDate.getHours() + ':' + String(targetDate.getMinutes()).padStart(2, '0')
			when targetDate.getFullYear() == currentDate.getFullYear()
				months[targetDate.getMonth()].short_name + ' ' + targetDate.getDate()
			else
				months[targetDate.getMonth()].short_name + ' ' + targetDate.getFullYear()
	
	msToRelTimeStr: (ms, { abbr = false, endMs = Time.unixMs() } = {}) ->
		duration = Time.msToTopDuration(endMs - ms, { trunc: true })
		if duration.unit.abbr != 'ms'
			if abbr
				return "#{duration.count}#{duration.unit.abbr}"
			else
				return "#{duration.count} #{duration.unit.name}#{if duration.count is 1 then '' else 's'}"
		else
			return 'now'

}

Time.unixS = ->
	Time.msToS(Time.unixMs(), { trunc: true })
Time.sToAge = (s) ->
	Time.msToAge(Time.sToMs(s))
Time.sToAbsTimeStr = (s) ->
	Time.msToAbsTimeStr(Time.sToMs(s))
Time.sToAbsRelTimeStr = (s) ->
	Time.msToAbsRelTimeStr(Time.sToMs(s))
Time.sToRelTimeStr = (s, { abbr, endS } = {}) ->
	Time.msToRelTimeStr(Time.sToMs(s), { abbr, endMs: if endS then Time.sToMs(endS) })
Time.sToMediaDurationStr = (s) ->
	Time.msToMediaDurationStr(Time.sToMs(s))

export default Time