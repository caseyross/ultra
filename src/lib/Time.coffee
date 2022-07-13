units =
	year:
		name: 'year'
		short_name: 'y'
		value: 1000 * 60 * 60 * 24 * 366
	month:
		name: 'month'
		short_name: 'mth'
		value: 1000 * 60 * 60 * 24 * 31
	week:
		name: 'week'
		short_name: 'w'
		value: 1000 * 60 * 60 * 24 * 7
	day:
		name: 'day'
		short_name: 'd'
		value: 1000 * 60 * 60 * 24
	hour:
		name: 'hour'
		short_name: 'h'
		value: 1000 * 60 * 60
	minute:
		name: 'minute'
		short_name: 'm'
		value: 1000 * 60
	second:
		name: 'second'
		short_name: 's'
		value: 1000
	millisecond:
		name: 'millisecond'
		short_name: 'ms'
		value: 0

export default {

	epochMs: ->
		Date.now()

	sToMs: (s) ->
		units.second.value * s
	mToMs: (m) ->
		units.minute.value * m
	hToMs: (h) ->
		units.hour.value * h

	msToS: (ms, options = { trunc: false }) ->
		s = ms / units.second.value
		return if options.trunc then Math.trunc(s) else s
	msToM: (ms, options = { trunc: false }) ->
		m = ms / units.minute.value
		return if options.trunc then Math.trunc(m) else m
	msToH: (ms, options = { trunc: false }) ->
		h = ms / units.hour.value
		return if options.trunc then Math.trunc(h) else h

	msToDuration: (ms, options = { trunc: true }) ->
		for id, unit of units
			if ms > unit.value
				count = ms / unit.value
				return {
					count: if options.trunc then Math.trunc(count) else count
					unit: unit
				}

	localHour: ->
		(new Date()).getHours()

}