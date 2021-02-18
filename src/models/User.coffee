export default class User
	constructor: ({ name, flair }) ->
		# static
		@name = name
		@flair = flair
		# derived
		@href = '/u/' + @name