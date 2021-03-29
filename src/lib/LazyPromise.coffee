window.LazyPromise = class
	constructor: (f) ->
		@ran = false
		@result = undefined
		@run = () ->
			if not @ran
				@ran = true
				@result = f()
			@result