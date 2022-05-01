daysOfTheWeek = [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ]

export default {

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
		when 'admin' then 'Admin'
		when 'moderator' then 'Moderator'
		when 'special' then 'Ex-Admin'
		else ''

	score: (input) -> switch
		when not Number.isFinite(input) then 'New'
		when input < 0 then input
		else '+' + input
		
}