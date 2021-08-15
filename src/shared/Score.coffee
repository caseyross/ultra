export default class Score
	constructor: ({ value, hidden }) ->
		if hidden
			@value = NaN
			@text = '*'
		else
			@value = value
			@text = String(value)