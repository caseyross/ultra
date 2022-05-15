Date.seconds = (numSeconds) ->
	1000 * numSeconds
Date.minutes = (numMinutes) ->
	1000 * 60 * numMinutes
Date.hours = (numHours) ->
	1000 * 60 * 60 * numHours

Date.asSeconds = (numMilliseconds) ->
	numMilliseconds // 1000
Date.asMinutes = (numMilliseconds) ->
	numMilliseconds / 60 // 1000
Date.asHours = (numMilliseconds) ->
	numMilliseconds / 60 / 60 // 1000