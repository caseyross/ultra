export default class Score
	constructor: ({ value, hidden }) ->
		if hidden
			@value = NaN
			@display_value = '(h)'
		else
			@value = value
			@display_value = switch
				when value > 999
					'+' + (value // 1000) + '.' + (value // 10000) + 'k'
				when value > -1
					'+' + value
				when value > -1000
					value
				when value <= -1000
					'-' + (Math.abs(value) // 1000) + '.' + (Math.abs(value) // 10000) + 'k'
				else
					'n/a'