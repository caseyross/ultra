export default class Distinguish
	constructor: ({ naive_type, is_op }) ->
		switch naive_type
			when 'moderator'
				@type = 'mod'
				@color = 'white'
				@bg_color = 'green'
			when 'admin'
				@type = 'admin'
				@color = 'white'
				@bg_color = 'orangered'
			when 'special'
				@type = 'special'
				@color = 'white'
				@bg_color = 'black'
			else
				if is_op
					@type = 'op'
					@color = 'white'
					@bg_color = 'blue'
				else
					@type = 'none'
					@color = ''
					@bg_color = ''