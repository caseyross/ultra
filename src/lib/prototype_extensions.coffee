Array::last = -> @[@.length - 1]
Date::toRelativeString = -> switch
	when (secondsAgo = (Date.now() - @valueOf()) // 1000) < 60 then secondsAgo + 's'
	when (minutesAgo = secondsAgo // 60) < 60 then minutesAgo + 'm'
	when (hoursAgo = minutesAgo // 60) < 24 then hoursAgo + 'h'
	when (daysAgo = hoursAgo // 24) < 7 then daysAgo + 'd'
	when (weeksAgo = daysAgo // 7) < 5 then weeksAgo + 'w'
	when (monthsAgo = weeksAgo // 4) < 12 then monthsAgo + 'mo'
	else (monthsAgo // 12) + 'y'
Object::fold = (a, b) -> @reduce(b, a)
String::pluralize = (count) -> @ + (if count is 1 then '' else 's')
