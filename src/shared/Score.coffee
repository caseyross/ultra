export default class Score
	constructor: ({ value, hidden }) ->
		if hidden
			@value = NaN
			@text = '*'
		else
			@value = value
			@text = switch
				when value > 0 then '+' + String(value)
				else String(value)