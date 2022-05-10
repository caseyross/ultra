daysOfTheWeek = [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ]

export default {

	commentBody: (input) ->
		input
			.slice(16, -6)
			.replace(/<p>&(#x200B|nbsp);<\/p>/g, "")
			.replace(/(%5C_|\\_)/g, "_")
			.replace(/<ul>\n<li>(.*)<\/li>\n<\/ul>/g, "<p>— $1<\/p>")

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

	postBody: (input) ->
		input
			.slice(31, -20)
			.replace(/<p>&(#x200B|nbsp);<\/p>/g, "")
			.replace(/(%5C_|\\_)/g, "_")
			.replace(/<p><a href="https:\/\/(i|preview).redd.it\/(.*)">(.*)<\/a><\/p>/g, "<figure class='selftext-media'><a href='https://$1.redd.it/$2' target='_blank'><img alt='$3' src='https://$1.redd.it/$2'></a></figure>")
			.replace(/<ul>\n<li>(.*)<\/li>\n<\/ul>/g, "<p>— $1<\/p>")

	score: (input) -> switch
		when not Number.isFinite(input) then 'New'
		when input < 0 then input
		else '+' + input
		
}