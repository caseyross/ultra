export default class RedditDistinguish
	constructor: (rawDistinguish, isOp) ->
		switch rawDistinguish
			when 'moderator'
				@type = 'mod'
				@color = 'white'
				@bgColor = 'green'
			when 'admin'
				@type = 'admin'
				@color = 'white'
				@bgColor = 'orangered'
			when 'special'
				@type = 'special'
				@color = 'white'
				@bgColor = 'black'
			else
				if isOp
					@type = 'op'
					@color = 'white'
					@bgColor = 'blue'
				else
					@type = 'none'
					@color = ''
					@bgColor = ''