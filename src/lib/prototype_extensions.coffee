Array::last = -> @[@.length - 1]
Date::toRelativeString = -> switch
	when (secondsAgo = (Date.now() - @valueOf()) // 1000) < 60 then secondsAgo + ' sec'
	when (minutesAgo = secondsAgo // 60) < 60 then minutesAgo + ' min'
	when (hoursAgo = minutesAgo // 60) < 24 then hoursAgo + ' hr'
	when (daysAgo = hoursAgo // 24) < 7 then daysAgo + ' days'
	when (weeksAgo = daysAgo // 7) < 5 then weeksAgo + ' weeks'
	when (monthsAgo = weeksAgo // 4) < 12 then monthsAgo + ' mth'
	else (monthsAgo // 12) + ' years'
Object::fold = (a, b) -> @reduce(b, a)
String::pluralize = (count) -> @ + (if count is 1 then '' else 's')
