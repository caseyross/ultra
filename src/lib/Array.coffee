Object.defineProperty(Array, 'last', {
	get: -> @[@.length - 1]
})

Array::fold = (accumulator, accumulationFunction) -> @.reduce(accumulationFunction, accumulator)

Array::partition = (testFunction) ->
	passed = []
	failed = []
	@.forEach((item) ->
		if testFunction(item)
			passed.push(item)
		else
			failed.push(item)
	)
	return [passed, failed]