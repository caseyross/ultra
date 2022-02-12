Object.defineProperty(Array, 'last', {
	get: -> @[@.length - 1]
})

Array::fold = (a, b) -> @reduce(b, a)