Date::toContextualString = ->
	monthText = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
	now = new Date()
	if now.getFullYear() is @getFullYear()
		if now.getMonth() is @getMonth() and now.getDate() is @getDate()
			# target is today.
			"#{@getHours()}:#{String(@getMinutes()).padStart(2, '0')}"
		else
			# target is a previous day in this year.
			"#{monthText[@getMonth()]} #{@getDate()}"
	else
		# target is a day in a previous year.
		"#{monthText[@getMonth()]} #{@getDate()} #{@getFullYear()}"
Date::toRelativeString = -> switch
	when (secondsAgo = (Date.now() - @valueOf()) // 1000) < 60 then secondsAgo + 's'
	when (minutesAgo = secondsAgo // 60) < 60 then minutesAgo + 'm'
	when (hoursAgo = minutesAgo // 60) < 24 then hoursAgo + 'h'
	when (daysAgo = hoursAgo // 24) < 7 then daysAgo + 'd'
	when (weeksAgo = daysAgo // 7) < 5 then weeksAgo + 'w'
	when (monthsAgo = weeksAgo // 4) < 12 then monthsAgo + 'mo'
	else (monthsAgo // 12) + 'y'
Object::fold = (a, b) -> @reduce(b, a)
String::getContrastColor = ->
	if not (@startsWith('#') and @length is 7) then 'inherit'
	red = Number.parseInt(@[1..2], 16) / 255
	green = Number.parseInt(@[3..4], 16) / 255
	blue = Number.parseInt(@[5..6], 16) / 255
	if (green + red / 8 + blue / 8) > 0.8 then 'black' else 'white'
String::getHtmlFromMarkdown = ->
	@
String::getNormalizedLength = ->
	x = encodeURI(@replace(/<[^>]+>/g, ''))
	x.length - 2 * x.split('%').length
String::pluralize = (count) -> @ + (if count is 1 then '' else 's')