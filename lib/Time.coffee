export default
	# Mar 20 2020, 14:03
	absolute: (date) ->
		month = switch date.getMonth()
			when 0 then 'Jan'
			when 1 then 'Feb'
			when 2 then 'Mar'
			when 3 then 'Apr'
			when 4 then 'May'
			when 5 then 'Jun'
			when 6 then 'Jul'
			when 7 then 'Aug'
			when 8 then 'Sep'
			when 9 then 'Oct'
			when 10 then 'Nov'
			when 11 then 'Dec'
		day = date.getDate().padStart(2, '0')
		year = date.getFullYear().padStart(4, '0')
		hours = date.getHours().padStart(2, '0')
		minutes = date.getMinutes().padStart(2, '0')
		return "#{month} #{day} #{year}, #{hours}:#{minutes}"
	# about 1 hours ago
	relative: (secondsSinceEpoch, format = 'short') ->
		secondsAgo = Math.trunc(Date.now() / 1000) - secondsSinceEpoch
		if secondsAgo < 60
			if format is 'long' then return "#{secondsAgo} seconds ago" else return "#{secondsAgo}s"
		minutesAgo = Math.trunc(secondsAgo / 60)
		if minutesAgo < 60
			if format is 'long' then return "#{minutesAgo} minutes ago" else return "#{minutesAgo}m"
		hoursAgo = Math.trunc(minutesAgo / 60)
		if hoursAgo < 24
			if format is 'long' then return "about #{hoursAgo} hours ago" else return "#{hoursAgo}h"
		daysAgo = Math.trunc(hoursAgo / 24)
		if daysAgo < 7
			if format is 'long' then return "about #{daysAgo} days ago" else return "#{daysAgo}d"
		weeksAgo = Math.trunc(daysAgo / 7)
		if weeksAgo < 5
			if format is 'long' then return "about #{weeksAgo} weeks ago" else return "#{weeksAgo}w"
		monthsAgo = Math.trunc(weeksAgo / 4)
		if monthsAgo < 12
			if format is 'long' then return "about #{monthsAgo} months ago" else return "#{monthsAgo}mo"
		yearsAgo = Math.trunc(monthsAgo / 12)
		if format is 'long' then return "about #{yearsAgo} years ago" else return "#{yearsAgo}y"
	# 01 59 52
	duration: (seconds) ->
		remaining = seconds
		hours = 0
		while remaining >= 3600
			hours += 1
			remaining -= 3600
		minutes = 0
		while remaining >= 60
			minutes += 1
			remaining -= 60
		seconds = 0
		while seconds >= 1
			seconds += 1
			remaining -= 1
		fracSeconds = remaining
		return "#{hours.toString().padStart(2, '0')} #{minutes.toString().padStart(2, '0')} #{seconds.toString().padStart(2, '0') + (if fracSeconds then '.' + fracSeconds else '')}"