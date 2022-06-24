import Time from '../../lib/Time.coffee'

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
			.replace(/&nbsp;/g, '')
			.replace(/&#x200B;/g, '')
			.replace(/<p>/g, '')
			.replace(/<\/p>/g, '')
			.replace(/<blockquote>\n+/g, '<blockquote>')
			.replace(/<\/blockquote>\n+/g, '<\/blockquote>\n')
			.replace(/<ol>\n/g, '<ol>')
			.replace(/\n<\/ol>\n/g, '</ol>')
			.replace(/<ul>\n/g, '<ul>')
			.replace(/\n<\/ul>\n/g, '</ul>')
			.replace(/<\/h1>\n/g, '<\/h1>')
			.replace(/<\/h2>\n/g, '<\/h2>')
			.replace(/<\/h3>\n/g, '<\/h3>')
			.replace(/<\/table>\n/g, '<\/table>')
			.replace(/(%5C_|\\_)/g, "_")

	date: (input) ->
		input = new Date(input)
		year = String(input.getFullYear())[2..].padStart(2, '0')
		month = String(input.getMonth() + 1)
		day = String(input.getDate())
		dayOfTheWeek = daysOfTheWeek[input.getDay()]
		hour = String(input.getHours())
		minute = String(input.getMinutes()).padStart(2, '0')
		return "#{month}/#{day}/#{year} (#{dayOfTheWeek}) #{if hour > 12 then hour % 12 else hour}:#{minute}#{if hour < 12 then 'am' else 'pm'}"

	distinguish: (input) -> switch input
		when 'admin' then '(reddit employee)'
		when 'moderator' then '(moderator)'
		when 'special' then '(reddit alumnus)'
		else ''

	durationMinutesSeconds: (input) ->
		seconds = Time.msToS(input, { trunc: true })
		minutes = 0
		while seconds >= 60
			seconds = seconds - 60
			minutes = minutes + 1
		return "#{String(minutes).padStart(2, '0')}:#{String(seconds).padStart(2, '0')}"

	percentage: (input) -> Math.trunc(100 * input)

	plusMinus: (input) ->
		if input > 0 then '+' + input
		else input

	postBody: (input) ->
		input
			.slice(31, -20)
			.replace(/&nbsp;/g, '')
			.replace(/&#x200B;/g, '')
			.replace(/<p>/g, '')
			.replace(/<\/p>/g, '')
			.replace(/<blockquote>\n+/g, '<blockquote>')
			.replace(/<\/blockquote>\n+/g, '<\/blockquote>\n')
			.replace(/<ol>\n/g, '<ol>')
			.replace(/\n<\/ol>\n/g, '</ol>')
			.replace(/<ul>\n/g, '<ul>')
			.replace(/\n<\/ul>\n/g, '</ul>')
			.replace(/<\/h1>\n/g, '<\/h1>')
			.replace(/<\/h2>\n/g, '<\/h2>')
			.replace(/<\/h3>\n/g, '<\/h3>')
			.replace(/<\/table>\n/g, '<\/table>')
			.replace(/(%5C_|\\_)/g, "_")
			.replace(/<a href="https:\/\/(i|preview).redd.it\/(.*?)">(.*?)<\/a>/g, "<figure class='post-selftext-media'><figcaption><a href='https://$1.redd.it/$2'>$3</a></figcaption><img alt='' src='https://$1.redd.it/$2'></figure>")
}