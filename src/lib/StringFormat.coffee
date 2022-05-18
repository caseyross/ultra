import Time from './Time.coffee'

count = (number, string) ->
	if number == 1 then "#{number} #{string}" else "#{number} #{string}s"
daysOfTheWeek = [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ]

export default {

	age: (input) ->
		millis = Time.epochMs() - input
		seconds = millis // 1000
		minutes = seconds // 60
		if minutes < 1 then return count(seconds, 'second')
		hours = minutes // 60
		if hours < 1 then return count(minutes, 'minute')
		days = hours // 24
		if days < 1 then return count(hours, 'hour')
		months = days // 31
		if months < 1 then return count(days, 'day')
		years = months // 12
		if years < 1 then return count(months, 'month') else return count(years, 'year')

	commentBody: (input) ->
		input
			.slice(16, -6)
			.replace(/<p>&(#x200B|nbsp);<\/p>/g, "")
			.replace(/(%5C_|\\_)/g, "_")

	date: (input) ->
		input = new Date(input)
		year = String(input.getFullYear())[2..].padStart(2, '0')
		month = String(input.getMonth() + 1).padStart(2, '0')
		day = String(input.getDate()).padStart(2, '0')
		dayOfTheWeek = daysOfTheWeek[input.getDay()]
		hour = String(input.getHours()).padStart(2, '0')
		minute = String(input.getMinutes()).padStart(2, '0')
		return "#{month}/#{day}/#{year} (#{dayOfTheWeek}) #{hour}:#{minute}"

	distinguish: (input) -> switch input
		when 'admin' then '(reddit employee)'
		when 'moderator' then '(moderator)'
		when 'special' then '(reddit alumnus)'
		else ''

	postBody: (input) ->
		input
			.slice(31, -20)
			.replace(/<p>&(#x200B|nbsp);<\/p>/g, "")
			.replace(/(%5C_|\\_)/g, "_")
			.replace(/<p><a href="https:\/\/(i|preview).redd.it\/(.*)">(.*)<\/a><\/p>/g, "<figure class='selftext-media'><a href='https://$1.redd.it/$2' target='_blank'><img alt='$3' src='https://$1.redd.it/$2'></a></figure>")

	score: (input) -> switch
		when not Number.isFinite(input) then 'New'
		when input < 0 then input
		else '+' + input
		
}