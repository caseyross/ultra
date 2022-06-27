import Time from './Time.coffee'

daysOfTheWeek = [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ]

export default {

	ago: (ms) ->
		duration = Time.msToDuration(Time.epochMs() - ms)
		return "#{duration.count} #{duration.unit.name}#{if duration.count is 1 then '' else 's'} ago"

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

}