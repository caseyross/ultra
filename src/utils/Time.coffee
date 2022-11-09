# Formatter is expensive to create, so we just maintain a singleton instance
abs_date_formatter = new Intl.DateTimeFormat('en-US', {
	weekday: 'long',
	year: 'numeric',
	month: 'long',
	day: 'numeric',
	hour: 'numeric',
	minute: 'numeric'
})

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

	msToTopDuration: (ms, opt = { trunc: true }) ->
		for id, unit of units
			if ms > unit.value
				count = ms / unit.value
				if opt.trunc
					return {
						count: Math.trunc(count),
						unit
					}
				else
					return {
						count,
						unit
					}
	
	msToMediaDurationStr: (ms) ->
		s = Time.msToS(ms, { trunc: true })
		m = 0
		while s >= 60
			s = s - 60
			m = m + 1
		return "#{String(m).padStart(2, '0')}:#{String(s).padStart(2, '0')}"
	
	msToAbsDateStr: (ms) -> abs_date_formatter.format(new Date(ms))
	
	msToRelDateStr: (ms, opt = { abbr: true }) ->
		duration = Time.msToTopDuration(Time.unixMs() - ms, { trunc: true })
		if duration.unit.abbr != 'ms'
			if opt.abbr
				return "#{duration.count}#{duration.unit.abbr}"
			else
				return "#{duration.count} #{duration.unit.name}#{if duration.count is 1 then '' else 's'}"
		else
			return '<1s'

}

Time.sToAbsDateStr = (s) ->
	Time.msToAbsDateStr(Time.sToMs(s))
Time.sToRelDateStr = (s, opt) ->
	Time.msToRelDateStr(Time.sToMs(s), opt)
Time.sToMediaDurationStr = (s) ->
	Time.msToMediaDurationStr(Time.sToMs(s))

export default Time