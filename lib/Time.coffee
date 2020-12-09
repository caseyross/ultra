monthText = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

export default
	contextualAbsolute: (secondsSinceEpoch) ->
		then = new Date(secondsSinceEpoch * 1000)
		now = new Date()
		if now.getFullYear() is then.getFullYear()
			if now.getMonth() is then.getMonth() and now.getDate() is then.getDate()
				# Target date is today.
				return "#{then.getHours()}:#{then.getMinutes().padStart(2, '0')}"
			else
				# Target date is a previous day in this year.
				return "#{monthText[then.getMonth()]} #{then.getDate()}"
		else
			# Target date is a day in a previous year.
			return "#{monthText[then.getMonth()]} #{then.getDate()} #{then.getFullYear()}"
	relative: (secondsSinceEpoch) -> switch
		when (secondsAgo = Date.now() // 1000 - secondsSinceEpoch) < 60
			"about #{secondsAgo} seconds ago"
		when (minutesAgo = secondsAgo // 60) < 60
			"about #{minutesAgo} minutes ago"
		when (hoursAgo = minutesAgo // 60) < 24
			"about #{hoursAgo} hours ago"
		when (daysAgo = hoursAgo // 24) < 7
			"about #{daysAgo} days ago"
		when (weeksAgo = daysAgo // 7) < 5
			"about #{weeksAgo} weeks ago"
		when (monthsAgo = weeksAgo // 4) < 12
			"about #{monthsAgo} months ago"
		else
			"about #{monthsAgo // 12} years ago"
	durationCounter: (seconds) ->
		secondsToAdd = seconds
		h = 0
		while secondsToAdd >= 3600
			h += 1
			secondsToAdd -= 3600
		m = 0
		while secondsToAdd >= 60
			m += 1
			secondsToAdd -= 60
		s = 0
		while secondsToAdd >= 1
			s += 1
			secondsToAdd -= 1
		return "#{h}:#{m.toString().padStart(2, '0')}:#{s.toString().padStart(2, '0')}"