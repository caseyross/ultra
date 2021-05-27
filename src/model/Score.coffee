export default class Score
	constructor: ({ value, hidden }) ->
		if hidden
			@value = NaN
			@text = if value > 0 then '+' else '-'
		else
			@value = value
			@text = String(value)